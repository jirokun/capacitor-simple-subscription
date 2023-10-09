//
//  Subscription.swift
//  SubscriptionManager
//
//  Created by Jiro Iwamoto on 2023/10/05.
//

import Foundation

internal struct Subscription: Codable {
    var productId: String
    var expirationDate: Date
}
