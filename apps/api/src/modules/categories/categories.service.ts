import { Injectable } from '@nestjs/common';
import type { Category } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class CategoriesService {
  constructor(private readonly prisma: PrismaService) {}

  list(): Promise<Category[]> {
    return this.prisma.category.findMany({ orderBy: [{ sortOrder: 'asc' }, { slug: 'asc' }] });
  }
}
