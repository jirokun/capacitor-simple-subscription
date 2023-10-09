import Foundation
import StoreKit
import AuthenticationServices


enum SubscribeError: LocalizedError {
    case userCancelled // ユーザーによって購入がキャンセルされた
    case pending // クレジットカードが未設定などの理由で購入が保留された
    case productUnavailable // 指定した商品が無効
    case purchaseNotAllowed // OSの支払い機能が無効化されている
    case failedVerification // トランザクションデータの署名が不正
    case otherError // その他のエラー
}

@objc public class SubscriptionManager: NSObject {
    internal static func storeSubscription(subscription: Subscription, productID: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(subscription) {
            UserDefaults.standard.set(encoded, forKey: "subscription:" + productID)
        }
    }

    private func purchase(product: Product) async throws -> Transaction {
        // Product.PurchaseResultの取得
        let purchaseResult: Product.PurchaseResult
        do {
            purchaseResult = try await product.purchase()
        } catch Product.PurchaseError.productUnavailable {
            throw SubscribeError.productUnavailable
        } catch Product.PurchaseError.purchaseNotAllowed {
            throw SubscribeError.purchaseNotAllowed
        } catch {
            throw SubscribeError.otherError
        }
        // VerificationResultの取得
        let verificationResult: VerificationResult<Transaction>
        switch purchaseResult {
        case .success(let result):
            verificationResult = result
        case .userCancelled:
            throw SubscribeError.userCancelled
        case .pending:
            throw SubscribeError.pending
        @unknown default:
            throw SubscribeError.otherError
        }

        // Transactionの取得
        switch verificationResult {
        case .verified(let transaction):
            return transaction
        case .unverified:
            throw SubscribeError.failedVerification
        }
    }

    @objc public func subscribe(_ productId: String) async {
        do {
            let products = try await Product.products(for: [productId])
            let product = products[0]
            
            if let status = try await product.subscription?.status {
                status.forEach {
                    switch $0.state {
                    case .expired:
                        print("expired")
                    case .inBillingRetryPeriod:
                        print("inBillingRetryPeriod")
                    case .inGracePeriod:
                        print("inGracePeriod")
                    case .revoked:
                        print("revoked")
                    case .subscribed:
                        print("subscribed")
                    default:
                        print("other")
                    }
                }
            }
            let transaction = try await self.purchase(product: product)
            let subscription = Subscription(productId: transaction.productID, expirationDate: transaction.expirationDate!)
            SubscriptionManager.storeSubscription(subscription: subscription, productID: transaction.productID)
            await transaction.finish()
            print("購入が完了しました。")
        } catch {
            print(error)
        }
    }
    
    @objc public func hasSubscription(_ productId: String) async -> Bool {
        if let json = UserDefaults.standard.object(forKey: "subscription:" + productId) as? Data {
            let decoder = JSONDecoder()
            if let loadedSubscription = try? decoder.decode(Subscription.self, from: json) {
                print(loadedSubscription.expirationDate)
                return loadedSubscription.expirationDate > Date()
            }
        }
        return false
    }

    @objc public func getSubscription(_ productId: String) async -> [String: Any]? {
        if let json = UserDefaults.standard.object(forKey: "subscription:" + productId) as? Data,
           let dict = try? JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String: Any] {
            return dict
        } else {
            return nil
        }
    }

    @objc public func showManageSubscriptions() async {
        // capacitorのpluginの中でsceneを取得する
        guard let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        // 現在の購読状況を確認する
        try? await AppStore.showManageSubscriptions(in: scene)
    }
    
    @objc public func restoreSubscription(_ productId: String) async {
        print("restore " + productId)
        for await verificationResult in Transaction.currentEntitlements {
            // 取り消しや払い戻された transaction は currentEntitlements には現れないので
            // transaction.revocationDate はチェックしなくて良い
            guard case .verified(let transaction) = verificationResult else { return }
            switch transaction.productType {
            case .autoRenewable:
                print("restore autoRenewable " + transaction.productID)
                // transaction が終了していなかった consumable が来る
                let subscription = Subscription(productId: transaction.productID, expirationDate: transaction.expirationDate!)
                SubscriptionManager.storeSubscription(subscription: subscription, productID: transaction.productID)
            default:
                print("restore default " + transaction.productID)
                break
            }
        }
    }
}
