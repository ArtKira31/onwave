import { AuthService } from './auth.service';
import { AppException } from '../../common/errors/app.exception';
import type { PrismaService } from '../../common/prisma/prisma.service';
import type { TokenService } from './token.service';
import type { OAuthVerifierService } from './oauth/oauth-verifier.service';
import type { User } from '@prisma/client';

const user = {
  id: 'u1',
  role: 'user',
  isGuest: true,
  displayName: null,
  email: null,
} as unknown as User;

function make(stored: unknown) {
  const tokens = {
    findRefreshToken: jest.fn().mockResolvedValue(stored),
    issuePair: jest.fn().mockResolvedValue({ accessToken: 'a', refreshToken: 'r', expiresIn: 900 }),
    revoke: jest.fn().mockResolvedValue(undefined),
    revokeFamily: jest.fn().mockResolvedValue(undefined),
    revokeForDevice: jest.fn().mockResolvedValue(undefined),
    revokeAllForUser: jest.fn().mockResolvedValue(undefined),
  };
  const prisma = {
    user: {
      upsert: jest.fn().mockResolvedValue(user),
      findFirst: jest.fn().mockResolvedValue(null),
      update: jest.fn().mockResolvedValue(user),
      create: jest.fn().mockResolvedValue(user),
    },
    favorite: { findMany: jest.fn().mockResolvedValue([]), createMany: jest.fn() },
  };
  const oauth = { verify: jest.fn() };
  const limits = { consume: jest.fn().mockResolvedValue(undefined) };
  const config = { get: jest.fn().mockReturnValue(20) };
  const service = new AuthService(
    prisma as unknown as PrismaService,
    tokens as unknown as TokenService,
    oauth as unknown as OAuthVerifierService,
    limits as never,
    config as never,
  );
  return { service, tokens, prisma, oauth, limits };
}

const live = {
  id: 't1',
  userId: 'u1',
  familyId: 'fam-1',
  deviceId: 'dev-1',
  revokedAt: null,
  expiresAt: new Date(Date.now() + 86_400_000),
  user,
};

describe('AuthService', () => {
  describe('гостевая сессия', () => {
    it('не плодит пользователей на один device-id', async () => {
      const { service, prisma } = make(null);
      await service.createGuestSession('dev-1');
      expect(prisma.user.upsert).toHaveBeenCalledWith(
        expect.objectContaining({ where: { deviceId: 'dev-1' } }),
      );
    });
  });

  describe('ротация refresh', () => {
    it('гасит предъявленный токен и выдаёт новый в той же цепочке', async () => {
      const { service, tokens } = make(live);
      await service.refresh('raw');
      expect(tokens.revoke).toHaveBeenCalledWith('t1');
      expect(tokens.issuePair).toHaveBeenCalledWith(user, 'dev-1', 'fam-1');
    });

    it('на переиспользование погашенного токена отзывает всю цепочку', async () => {
      // Либо токен украли и им воспользовались, либо им пользуются параллельно
      // с легальным клиентом. В обоих случаях цепочке доверять нельзя.
      const { service, tokens } = make({ ...live, revokedAt: new Date() });
      await expect(service.refresh('raw')).rejects.toThrow(AppException);
      expect(tokens.revokeFamily).toHaveBeenCalledWith('fam-1');
      expect(tokens.issuePair).not.toHaveBeenCalled();
    });

    it('не выдаёт пару по истёкшему токену', async () => {
      const { service, tokens } = make({ ...live, expiresAt: new Date(Date.now() - 1000) });
      await expect(service.refresh('raw')).rejects.toThrow(AppException);
      expect(tokens.issuePair).not.toHaveBeenCalled();
    });

    it('не выдаёт пару по неизвестному токену', async () => {
      const { service, tokens } = make(null);
      await expect(service.refresh('raw')).rejects.toThrow(AppException);
      expect(tokens.revokeFamily).not.toHaveBeenCalled();
    });
  });

  describe('выход', () => {
    it('гасит только текущее устройство', async () => {
      const { service, tokens } = make(live);
      await service.logout('u1', 'dev-1');
      expect(tokens.revokeForDevice).toHaveBeenCalledWith('u1', 'dev-1');
      expect(tokens.revokeAllForUser).not.toHaveBeenCalled();
    });

    it('без device-id гасит все сессии: развести их иначе нельзя', async () => {
      const { service, tokens } = make(live);
      await service.logout('u1', null);
      expect(tokens.revokeAllForUser).toHaveBeenCalledWith('u1');
    });
  });

  describe('вход через провайдера', () => {
    const identity = {
      subject: 'google-sub-1',
      email: 'kira@example.com',
      emailVerified: true,
      name: 'Кира',
      avatarUrl: null,
    };

    it('находит пользователя по sub провайдера, а не по email', async () => {
      // Email у Google можно сменить, у Apple при private relay он подставной.
      const { service, prisma, oauth } = make(null);
      oauth.verify.mockResolvedValue(identity);
      prisma.user.findFirst.mockResolvedValueOnce({ ...user, id: 'existing' });

      await service.loginWithOAuth('google', 'tok', 'dev-1');

      expect(prisma.user.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({ googleSub: 'google-sub-1' }),
        }),
      );
      expect(prisma.user.create).not.toHaveBeenCalled();
    });

    it('связывает с существующим аккаунтом только по верифицированному email', async () => {
      const { service, prisma, oauth } = make(null);
      oauth.verify.mockResolvedValue({ ...identity, emailVerified: false });
      prisma.user.findFirst.mockResolvedValue(null);

      await service.loginWithOAuth('google', 'tok', 'dev-1');

      // Связывание по непроверенному адресу — это захват чужой учётки
      // по незанятому email, поэтому создаётся новый пользователь.
      const byEmail = prisma.user.findFirst.mock.calls.some(
        ([arg]) => 'email' in (arg?.where ?? {}),
      );
      expect(byEmail).toBe(false);
    });

    it('апгрейдит гостя этого устройства вместо создания второго аккаунта', async () => {
      const { service, prisma, oauth } = make(null);
      oauth.verify.mockResolvedValue(identity);
      prisma.user.findFirst
        .mockResolvedValueOnce(null) // по sub не нашли
        .mockResolvedValueOnce(null) // по email не нашли
        .mockResolvedValueOnce({ ...user, id: 'guest-1', isGuest: true }); // гость есть

      await service.loginWithOAuth('google', 'tok', 'dev-1');

      expect(prisma.user.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'guest-1' },
          data: expect.objectContaining({ isGuest: false, googleSub: 'google-sub-1' }),
        }),
      );
      expect(prisma.user.create).not.toHaveBeenCalled();
    });

    it('переносит избранное гостя, когда аккаунт уже существовал', async () => {
      // Иначе всё, что человек отметил до логина, пропадает ровно в тот момент,
      // когда он решил завести аккаунт.
      const { service, prisma, oauth } = make(null);
      oauth.verify.mockResolvedValue(identity);
      prisma.user.findFirst
        .mockResolvedValueOnce({ ...user, id: 'existing', displayName: 'Кира' })
        .mockResolvedValueOnce({ ...user, id: 'guest-1', isGuest: true });
      prisma.favorite.findMany.mockResolvedValue([{ eventId: 'e1' }, { eventId: 'e2' }]);

      await service.loginWithOAuth('google', 'tok', 'dev-1');

      expect(prisma.favorite.createMany).toHaveBeenCalledWith(
        expect.objectContaining({
          data: [
            { userId: 'existing', eventId: 'e1' },
            { userId: 'existing', eventId: 'e2' },
          ],
          skipDuplicates: true,
        }),
      );
    });

    it('сохраняет имя от Apple: второй раз его не пришлют', async () => {
      const { service, prisma, oauth } = make(null);
      oauth.verify.mockResolvedValue({ ...identity, name: null });
      prisma.user.findFirst
        .mockResolvedValueOnce({ ...user, id: 'existing', displayName: null })
        .mockResolvedValueOnce(null);

      await service.loginWithOAuth('apple', 'tok', 'dev-1', 'Кира Артебякина');

      expect(prisma.user.update).toHaveBeenCalledWith(
        expect.objectContaining({ data: { displayName: 'Кира Артебякина' } }),
      );
    });
  });
});
