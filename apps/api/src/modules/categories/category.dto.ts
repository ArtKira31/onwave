import { ApiProperty } from '@nestjs/swagger';
import type { Category } from '@prisma/client';

export class CategoryDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty()
  slug!: string;

  @ApiProperty({
    example: 'category.concerts',
    description: 'Ключ локализации, не готовая строка: переводы живут в мобилке.',
  })
  nameKey!: string;

  @ApiProperty({ nullable: true, type: String })
  icon!: string | null;

  @ApiProperty()
  sortOrder!: number;

  static from(category: Category): CategoryDto {
    return {
      id: category.id,
      slug: category.slug,
      nameKey: category.nameKey,
      icon: category.icon,
      sortOrder: category.sortOrder,
    };
  }
}

export class CategoryListDto {
  @ApiProperty({ type: [CategoryDto] })
  items!: CategoryDto[];
}
