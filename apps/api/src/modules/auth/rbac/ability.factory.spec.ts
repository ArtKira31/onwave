import { AbilityFactory, Action } from './ability.factory';
import type { AccessTokenPayload } from '../token.service';

const factory = new AbilityFactory();

const who = (role: AccessTokenPayload['role'], isGuest = false, sub = 'me'): AccessTokenPayload => ({
  sub,
  role,
  isGuest,
  deviceId: 'dev',
});

const event = (over: Record<string, unknown> = {}) => ({
  authorId: 'me',
  status: 'draft',
  __caslSubjectType__: 'Event',
  ...over,
});

describe('матрица прав', () => {
  describe('аноним и гость', () => {
    it('читают опубликованное', () => {
      expect(factory.forUser().can(Action.Read, event({ status: 'published' }))).toBe(true);
      expect(
        factory.forUser(who('user', true)).can(Action.Read, event({ status: 'published' })),
      ).toBe(true);
    });

    it('не видят чужой черновик', () => {
      expect(
        factory.forUser().can(Action.Read, event({ authorId: 'other', status: 'draft' })),
      ).toBe(false);
    });

    it('не создают события: гостю нужен аккаунт', () => {
      expect(factory.forUser(who('user', true)).can(Action.Create, 'Event')).toBe(false);
    });
  });

  describe('пользователь', () => {
    const user = factory.forUser(who('user'));

    it('создаёт события', () => {
      expect(user.can(Action.Create, 'Event')).toBe(true);
    });

    it('видит свой черновик', () => {
      expect(user.can(Action.Read, event({ status: 'draft' }))).toBe(true);
    });

    it('правит свой черновик, отклонённое и опубликованное', () => {
      for (const status of ['draft', 'rejected', 'published']) {
        expect(user.can(Action.Update, event({ status }))).toBe(true);
      }
    });

    it('не правит своё, пока оно на модерации', () => {
      // Иначе автор мог бы подменить содержимое, пока модератор его смотрит.
      expect(user.can(Action.Update, event({ status: 'pending' }))).toBe(false);
    });

    it('не трогает чужое', () => {
      expect(user.can(Action.Update, event({ authorId: 'other' }))).toBe(false);
      expect(user.can(Action.Delete, event({ authorId: 'other' }))).toBe(false);
    });

    it('не модерирует', () => {
      expect(user.can(Action.Moderate, 'Event')).toBe(false);
    });
  });

  describe('модератор', () => {
    const moderator = factory.forUser(who('moderator'));

    it('видит чужие неопубликованные события', () => {
      expect(moderator.can(Action.Read, event({ authorId: 'other', status: 'pending' }))).toBe(true);
    });

    it('модерирует', () => {
      expect(moderator.can(Action.Moderate, 'Event')).toBe(true);
    });

    it('но не правит чужое событие как автор', () => {
      expect(moderator.can(Action.Update, event({ authorId: 'other', status: 'draft' }))).toBe(false);
    });
  });

  describe('админ', () => {
    it('может всё', () => {
      const admin = factory.forUser(who('admin'));
      expect(admin.can(Action.Moderate, 'Event')).toBe(true);
      expect(admin.can(Action.Update, event({ authorId: 'other', status: 'pending' }))).toBe(true);
      expect(admin.can(Action.Delete, 'User')).toBe(true);
    });
  });
});
