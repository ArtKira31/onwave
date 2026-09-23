import { Module } from '@nestjs/common';
import { CitiesModule } from '../cities/cities.module';
import { EventsController } from './events.controller';
import { EventsService } from './events.service';

@Module({
  imports: [CitiesModule],
  controllers: [EventsController],
  providers: [EventsService],
})
export class EventsModule {}
