import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { MediaController } from './media.controller';
import { MediaService } from './media.service';
import { MediaProcessor } from './media.processor';
import { MediaCleanupService } from './media-cleanup.service';
import { MEDIA_QUEUE } from './media.constants';

@Module({
  imports: [BullModule.registerQueue({ name: MEDIA_QUEUE })],
  controllers: [MediaController],
  providers: [MediaService, MediaProcessor, MediaCleanupService],
  exports: [MediaService],
})
export class MediaModule {}
