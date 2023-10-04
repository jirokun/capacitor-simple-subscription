export interface SubscriptionManagerPlugin {
  subscribe(options: { productId: string }): Promise<void>;
  hasSubscription(options: {
    productId: string;
  }): Promise<{ hasSubscription: boolean }>;
  showManageSubscriptions(): Promise<void>;
}
