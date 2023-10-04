import { WebPlugin } from '@capacitor/core';

import type { SubscriptionManagerPlugin } from './definitions';

export class SubscriptionManagerWeb
  extends WebPlugin
  implements SubscriptionManagerPlugin
{
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
