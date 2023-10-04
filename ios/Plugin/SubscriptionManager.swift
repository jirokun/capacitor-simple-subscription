import Foundation
import StoreKit


enum SubscribeError: LocalizedError {
    case userCancelled // ユーザーによって購入がキャンセルされた
    case pending // クレジットカードが未設定などの理由で購入が保留された
    case productUnavailable // 指定した商品が無効
    case purchaseNotAllowed // OSの支払い機能が無効化されている
    case failedVerification // トランザクションデータの署名が不正
    case otherError // その他のエラー
}

@objc public class SubscriptionManager: NSObject {
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
            print(product.displayName)
            let transaction = try await self.purchase(product: product)
            print(transaction.expirationDate?.ISO8601Format())
            print("AAAAAAAAAA")
            await transaction.finish()
            print("購入が完了しました。")
        } catch {
            print(error)
        }
    }
    
    @objc public func hasSubscription(_ _productId: String) async -> Bool {
        var validSubscription: Transaction?
        for await verificationResult in Transaction.currentEntitlements {
            if case .verified(let transaction) = verificationResult,
               transaction.productType == .autoRenewable && !transaction.isUpgraded {
                validSubscription = transaction
            }
        }
        if let productId = validSubscription?.productID {
            // 特典を付与
            return true
        } else {
            return false
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
}
