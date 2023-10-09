export interface SubscriptionManagerPlugin {
  subscribe(options: { productId: string }): Promise<void>;
  hasSubscription(options: {
    productId: string;
  }): Promise<{ hasSubscription: boolean }>;
  getSubscription(options: { productId: string }): Promise<{
    subscription: {
      productId: string;
      expirationDate: Date;
    };
  }>;
  showManageSubscriptions(): Promise<void>;
  restoreSubscription(options: { productId: string }): Promise<void>;
}
