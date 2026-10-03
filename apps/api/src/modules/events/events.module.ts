import { Module } from '@nestjs/common';
import { CitiesModule } from '../cities/cities.module';
import { FavoritesModule } from '../favorites/favorites.module';
import { SafetyModule } from '../safety/safety.module';
import { EventsController, MyEventsController } from './events.controller';
import { EventsService } from './events.service';
import { EventWritesService } from './event-writes.service';
import { EventStatusService } from './event-status.service';

@Module({
  imports: [CitiesModule, FavoritesModule, SafetyModule],
  controllers: [EventsController, MyEventsController],
  providers: [EventsService, EventWritesService, EventStatusService],
})
export class EventsModule {}
