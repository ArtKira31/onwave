import { Module } from '@nestjs/common';
import { SafetyController } from './safety.controller';
import { ReportsService } from './reports.service';
import { BlocksService } from './blocks.service';
import { EventStatusService } from '../events/event-status.service';

@Module({
  controllers: [SafetyController],
  providers: [ReportsService, BlocksService, EventStatusService],
  exports: [BlocksService],
})
export class SafetyModule {}
