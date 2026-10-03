import { Module } from '@nestjs/common';
import { ModerationController } from './moderation.controller';
import { ModerationService } from './moderation.service';
import { EventStatusService } from '../events/event-status.service';

@Module({
  controllers: [ModerationController],
  providers: [ModerationService, EventStatusService],
})
export class ModerationModule {}
