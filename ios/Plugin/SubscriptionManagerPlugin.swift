import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(SubscriptionManagerPlugin)
public class SubscriptionManagerPlugin: CAPPlugin {
    private let implementation = SubscriptionManager()
    
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
    
    @objc func showManageSubscriptions(_ call: CAPPluginCall) {
        Task {
            await implementation.showManageSubscriptions()
            call.resolve()
        }
    }
}
