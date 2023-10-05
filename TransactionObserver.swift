import StoreKit

// アプリ起動時に、AppDelegateやSwiftUIならRootなViewなどでこのclassを保持し、
// Transactionをlistenし続ける

final class TransactionObserver {
    var updates: Task<Void, Never>? = nil
    
    init() {
        updates = newTransactionListenerTask()
    }

    deinit {
        // Cancel the update handling task when you deinitialize the class.
        updates?.cancel()
    }
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                self.handle(updatedTransaction: verificationResult)
            }
        }
    }
    
    private func storeSubscription(subscription: Subscription, productID: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(subscription) {
            UserDefaults.standard.set(encoded, forKey: "subscription:" + productID)
        }
    }
    
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) {
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            return
        }

        if let revocationDate = transaction.revocationDate {
            // Remove access to the product identified by transaction.productID.
            // Transaction.revocationReason provides details about
            // the revoked transaction.
            print("handle revocation")
            let subscription = Subscription(productID: transaction.productID, expirationDate: revocationDate)
            self.storeSubscription(subscription: subscription, productID: transaction.productID)
        } else if let expirationDate = transaction.expirationDate,
            expirationDate < Date() {
            print("handle expired")
            return
        } else if transaction.isUpgraded {
            print("handle upgraded")
            return
        } else {
            print("handle subscription")
            let subscription = Subscription(productID: transaction.productID, expirationDate: transaction.expirationDate!)
            self.storeSubscription(subscription: subscription, productID: transaction.productID)
        }
    }
}
