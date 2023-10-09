import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(SubscriptionManagerPlugin)
public class SubscriptionManagerPlugin: CAPPlugin {
    private let implementation = SubscriptionManager()
    private let transactionObserver = TransactionObserver()
    
    @objc func subscribe(_ call: CAPPluginCall) {
        Task {
            let productId = call.getString("productId") ?? ""
            await implementation.subscribe(productId)
            call.resolve()
        }
    }
    
    @objc func hasSubscription(_ call: CAPPluginCall) {
        let productId = call.getString("productId") ?? ""
        Task {
            let ret = await implementation.hasSubscription(productId)
            call.resolve([
                "hasSubscription": ret
            ])
        }
    }

    @objc func getSubscription(_ call: CAPPluginCall) {
        let productId = call.getString("productId") ?? ""
        Task {
            let ret = await implementation.getSubscription(productId)
            call.resolve([
                "subscription": ret as Any
            ])
        }
    }

    @objc func showManageSubscriptions(_ call: CAPPluginCall) {
        Task {
            await implementation.showManageSubscriptions()
            call.resolve()
        }
    }
    
    @objc func restoreSubscription(_ call: CAPPluginCall) {
        Task {
            let productId = call.getString("productId") ?? ""
            await implementation.restoreSubscription(productId)
            call.resolve()
        }
    }
}
