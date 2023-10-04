import { WebPlugin } from '@capacitor/core';

import type { SubscriptionManagerPlugin } from './definitions';

export class SubscriptionManagerWeb
  extends WebPlugin
  implements SubscriptionManagerPlugin
{
  async subscribe(options: { productId: string }): Promise<void> {
    console.log('Cannot use this method on web');
  }
  async hasSubscription(options: {
    productId: string;
  }): Promise<{ value: boolean }> {
    console.log('Cannot use this method on web');
    return { value: false };
  }
}
