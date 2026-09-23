import { Module } from '@nestjs/common';
import { CitiesModule } from '../cities/cities.module';
import { FavoritesModule } from '../favorites/favorites.module';
import { EventsController } from './events.controller';
import { EventsService } from './events.service';

@Module({
  imports: [CitiesModule, FavoritesModule],
  controllers: [EventsController],
  providers: [EventsService],
})
export class EventsModule {}
