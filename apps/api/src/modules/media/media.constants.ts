export const MEDIA_QUEUE = 'media';
export const RESIZE_JOB = 'resize';

export interface ResizeJobData {
  assetId: string;
}

/** Три размера: лента, карточка, полноэкранный просмотр. */
export const VARIANTS = [
  { name: 'thumb', width: 400 },
  { name: 'medium', width: 900 },
  { name: 'large', width: 1800 },
] as const;
