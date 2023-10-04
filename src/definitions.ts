export interface SubscriptionManagerPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
