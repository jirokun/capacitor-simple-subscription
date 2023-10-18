export interface SubscriptionManagerPlugin {
  subscribe(options: { productId: string }): Promise<void>;
  hasValidSubscription(options: {
    productId: string;
  }): Promise<{ hasValidSubscription: boolean }>;
  getSubscription(options: { productId: string }): Promise<{
    subscription: {
      productId: string;
      expirationDate: Date;
    };
  }>;
  showManageSubscriptions(): Promise<void>;
  restoreSubscription(options: { productId: string }): Promise<void>;
}
