import { registerPlugin } from '@capacitor/core';

import type { WatchMessagePlugin } from './definitions';

export const WatchMessage = registerPlugin<WatchMessagePlugin>('CapacitorWatchMessage', {
  web: () => {
    throw new Error('Not implemented for web');
  },
});

export * from './definitions';