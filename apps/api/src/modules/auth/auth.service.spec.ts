import { AuthService } from './auth.service';
import { AppException } from '../../common/errors/app.exception';
import type { PrismaService } from '../../common/prisma/prisma.service';
import type { TokenService } from './token.service';

const user = { id: 'u1', role: 'user', isGuest: true } as never;

function make(stored: unknown) {
  const tokens = {
    findRefreshToken: jest.fn().mockResolvedValue(stored),
    issuePair: jest.fn().mockResolvedValue({ accessToken: 'a', refreshToken: 'r', expiresIn: 900 }),
    revoke: jest.fn().mockResolvedValue(undefined),
    revokeFamily: jest.fn().mockResolvedValue(undefined),
    revokeForDevice: jest.fn().mockResolvedValue(undefined),
    revokeAllForUser: jest.fn().mockResolvedValue(undefined),
  };
  const prisma = { user: { upsert: jest.fn().mockResolvedValue(user) } };
  const service = new AuthService(
    prisma as unknown as PrismaService,
    tokens as unknown as TokenService,
  );
  return { service, tokens, prisma };
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
});
