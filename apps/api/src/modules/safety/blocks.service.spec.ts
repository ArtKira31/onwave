import { BlocksService } from './blocks.service';
import { AppException } from '../../common/errors/app.exception';
import type { PrismaService } from '../../common/prisma/prisma.service';
import type { RedisService } from '../../common/redis/redis.service';

function make(rows: { blockerId: string; blockedId: string }[] = [], cached: string | null = null) {
  const redisClient = {
    get: jest.fn().mockResolvedValue(cached),
    set: jest.fn().mockResolvedValue('OK'),
    del: jest.fn().mockResolvedValue(1),
  };
  const prisma = {
    userBlock: {
      findMany: jest.fn().mockResolvedValue(rows),
      upsert: jest.fn().mockResolvedValue({}),
      deleteMany: jest.fn().mockResolvedValue({ count: 1 }),
    },
    user: { findFirst: jest.fn().mockResolvedValue({ id: 'them' }) },
  };
  const service = new BlocksService(
    prisma as unknown as PrismaService,
    { client: redisClient } as unknown as RedisService,
  );
  return { service, prisma, redisClient };
}

describe('BlocksService', () => {
  describe('кого скрывать', () => {
    it('скрывает и тех, кого я заблокировал, и тех, кто заблокировал меня', async () => {
      // Односторонняя фильтрация защищает только на словах: преследователь
      // продолжал бы видеть события того, кто от него закрылся.
      const { service } = make([
        { blockerId: 'me', blockedId: 'i-blocked-them' },
        { blockerId: 'they-blocked-me', blockedId: 'me' },
      ]);

      const hidden = await service.hiddenAuthorIds('me');

      expect(hidden.sort()).toEqual(['i-blocked-them', 'they-blocked-me']);
    });

    it('не возвращает самого себя', async () => {
      const { service } = make([{ blockerId: 'me', blockedId: 'other' }]);
      expect(await service.hiddenAuthorIds('me')).not.toContain('me');
    });

    it('у анонима скрывать нечего и в базу не ходит', async () => {
      const { service, prisma } = make();
      expect(await service.hiddenAuthorIds(undefined)).toEqual([]);
      expect(prisma.userBlock.findMany).not.toHaveBeenCalled();
    });

    it('берёт список из кэша, не трогая базу', async () => {
      const { service, prisma } = make([], 'a,b');
      expect(await service.hiddenAuthorIds('me')).toEqual(['a', 'b']);
      expect(prisma.userBlock.findMany).not.toHaveBeenCalled();
    });

    it('отличает пустой кэш от отсутствующего', async () => {
      // Пустая строка означает «блокировок нет», а не «кэш пуст, иди в базу»:
      // иначе пользователь без блокировок ходил бы в базу на каждый запрос ленты.
      const { service, prisma } = make([], '');
      expect(await service.hiddenAuthorIds('me')).toEqual([]);
      expect(prisma.userBlock.findMany).not.toHaveBeenCalled();
    });
  });

  describe('блокировка', () => {
    it('сбрасывает кэш обеим сторонам', async () => {
      // Иначе у одной из них выдача останется прежней до конца TTL.
      const { service, redisClient } = make();
      await service.block('me', 'them');
      expect(redisClient.del).toHaveBeenCalledWith('blocks:me', 'blocks:them');
    });

    it('не даёт заблокировать самого себя', async () => {
      const { service } = make();
      await expect(service.block('me', 'me')).rejects.toThrow(AppException);
    });

    it('идемпотентна: повторная блокировка не ошибка', async () => {
      const { service, prisma } = make();
      await service.block('me', 'them');
      await service.block('me', 'them');
      expect(prisma.userBlock.upsert).toHaveBeenCalledTimes(2);
    });
  });
});
