import StoreKit

// アプリ起動時に、AppDelegateやSwiftUIならRootなViewなどでこのclassを保持し、
// Transactionをlistenし続ける

final class TransactionObserver {
    var updates: Task<Void, Never>? = nil
    
    init() {
        print("init")
        updates = newTransactionListenerTask()
    }

    deinit {
        // Cancel the update handling task when you deinitialize the class.
        updates?.cancel()
    }
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                await self.handle(updatedTransaction: verificationResult)
            }
        }
    }
    
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) async {
        print("handle")
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            return
        }

        if let revocationDate = transaction.revocationDate {
            // Remove access to the product identified by transaction.productID.
            // Transaction.revocationReason provides details about
            // the revoked transaction.
            print("handle revocation")
            let subscription = Subscription(productId: transaction.productID, expirationDate: revocationDate)
            SubscriptionManager.storeSubscription(subscription: subscription, productID: transaction.productID)
        } else if let expirationDate = transaction.expirationDate,
            expirationDate < Date() {
            print("handle expired")
        } else if transaction.isUpgraded {
            print("handle upgraded")
        } else {
            print("handle subscription")
            let subscription = Subscription(productId: transaction.productID, expirationDate: transaction.expirationDate!)
            SubscriptionManager.storeSubscription(subscription: subscription, productID: transaction.productID)
        }
        await transaction.finish()
    }
}
