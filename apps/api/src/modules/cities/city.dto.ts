import { ApiProperty } from '@nestjs/swagger';
import type { City } from '@prisma/client';

export class CityDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty()
  slug!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty({
    example: 'Asia/Tbilisi',
    description: 'IANA-таймзона. «Сегодня» считается по ней, а не по времени телефона.',
  })
  timezone!: string;

  @ApiProperty()
  lat!: number;

  @ApiProperty()
  lon!: number;

  static from(city: City): CityDto {
    return {
      id: city.id,
      slug: city.slug,
      name: city.name,
      timezone: city.timezone,
      lat: city.lat,
      lon: city.lon,
    };
  }
}

export class CityListDto {
  @ApiProperty({ type: [CityDto] })
  items!: CityDto[];
}
