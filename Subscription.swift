//
//  Subscription.swift
//  SubscriptionManager
//
//  Created by Jiro Iwamoto on 2023/10/05.
//

import Foundation

struct Subscription: Codable {
    var productID: String
    var expirationDate: Date
}
