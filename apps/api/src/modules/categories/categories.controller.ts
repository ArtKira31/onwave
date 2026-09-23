import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CategoriesService } from './categories.service';
import { CategoryDto, CategoryListDto } from './category.dto';

@ApiTags('categories')
@Controller('categories')
export class CategoriesController {
  constructor(private readonly categories: CategoriesService) {}

  @Get()
  @ApiOperation({
    operationId: 'listCategories',
    summary: 'Справочник категорий',
    description: 'Набор фиксированный, засевается миграцией. Доступен гостю.',
  })
  @ApiOkResponse({ type: CategoryListDto })
  async list(): Promise<CategoryListDto> {
    const categories = await this.categories.list();
    return { items: categories.map(CategoryDto.from) };
  }
}
