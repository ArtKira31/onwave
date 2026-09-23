import { HttpStatus, Injectable } from '@nestjs/common';
import type { City } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-codes';

@Injectable()
export class CitiesService {
  constructor(private readonly prisma: PrismaService) {}

  /** Неактивные города в выдачу не попадают: заведены, но ещё не открыты. */
  list(): Promise<City[]> {
    return this.prisma.city.findMany({
      where: { isActive: true },
      orderBy: [{ popularity: 'desc' }, { name: 'asc' }],
    });
  }

  /**
   * Лента принимает и slug, и id — в ссылках удобнее slug, в коде id.
   * Таймзона нужна вызывающему для пресетов дат, поэтому возвращаем город целиком.
   */
  async resolve(slugOrId: string): Promise<City> {
    const city = await this.prisma.city.findFirst({
      where: { isActive: true, OR: [{ slug: slugOrId }, { id: slugOrId }] },
    });

    if (!city) {
      throw new AppException(
        ErrorCode.NOT_FOUND,
        `Город «${slugOrId}» не найден`,
        HttpStatus.NOT_FOUND,
      );
    }

    return city;
  }
}
