import Foundation

@objc public class SubscriptionManager: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
