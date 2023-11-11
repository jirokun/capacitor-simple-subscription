/* eslint-disable @typescript-eslint/no-unused-vars */
import { WebPlugin } from '@capacitor/core';

import type { SubscriptionManagerPlugin } from './definitions';

export class SubscriptionManagerWeb
  extends WebPlugin
  implements SubscriptionManagerPlugin
{
  getSubscription(_options: {
    productId: string;
  }): Promise<{ subscription: { productId: string; expirationDate: Date } }> {
    throw new Error('Method not implemented.');
  }
  showManageSubscriptions(): Promise<void> {
    throw new Error('Method not implemented.');
  }
  restoreSubscription(_options: { productId: string }): Promise<void> {
    throw new Error('Method not implemented.');
  }
  async subscribe(_options: { productId: string }): Promise<void> {
    throw new Error('Method not implemented.');
  }
  hasValidSubscription(_options: {
    productId: string;
  }): Promise<{ hasValidSubscription: boolean }> {
    throw new Error('Method not implemented.');
  }
}
