import { registerPlugin } from '@capacitor/core';

import type { SubscriptionManagerPlugin } from './definitions';

const SubscriptionManager = registerPlugin<SubscriptionManagerPlugin>(
  'SubscriptionManager',
  {
    web: () => import('./web').then(m => new m.SubscriptionManagerWeb()),
  },
);

export * from './definitions';
export { SubscriptionManager };
