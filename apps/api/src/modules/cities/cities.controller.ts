import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CitiesService } from './cities.service';
import { CityDto, CityListDto } from './city.dto';
import { Public } from '../auth/decorators/public.decorator';

@ApiTags('cities')
@Public()
@Controller('cities')
export class CitiesController {
  constructor(private readonly cities: CitiesService) {}

  @Get()
  @ApiOperation({
    operationId: 'listCities',
    summary: 'Активные города',
    description: 'Доступен гостю без авторизации. Сортировка по популярности, затем по алфавиту.',
  })
  @ApiOkResponse({ type: CityListDto })
  async list(): Promise<CityListDto> {
    const cities = await this.cities.list();
    return { items: cities.map(CityDto.from) };
  }
}
