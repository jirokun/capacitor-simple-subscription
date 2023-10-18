import XCTest
import StoreKit
import StoreKitTest
@testable import Plugin

class SubscriptionManagerTests: XCTestCase {
    private var session: SKTestSession!
    private let implementation = SubscriptionManager()
    private let productId = "SUBSCRIPTION_MANAGER_TEST"
    private var transactionObserver: TransactionObserver!
    
    override func setUp() {
        do {
            self.session = try SKTestSession(configurationFileNamed: "TestSubscriptions")
            self.session.disableDialogs = true
            self.session.askToBuyEnabled = false
            self.session.clearTransactions()
        } catch {
            XCTAssert(false)
        }
        transactionObserver = TransactionObserver()
    }
    
    override func tearDown() {
        session.clearTransactions()
    }
    
    func testStorekitTeting() async throws {
        let products = try await Product.products(for: [self.productId])
        XCTAssertEqual(1, products.count)
    }
    
    /**
     subscribe成功すること
     */
    func testSubscribe() async throws {
        XCTAssertEqual(self.session.allTransactions().count, 0)
        try await implementation.subscribe(productId)
        XCTAssert(self.session.allTransactions().count == 1)
        XCTAssert(self.session.allTransactions()[0].state == .purchased)
        let hasValidSubscription = await implementation.hasValidSubscription(productId)
        XCTAssert(hasValidSubscription == true)
    }
    
    /**
     subscribeが親の承認が必要で先送りになること
     */
    func testSubscribeWithParentApproval() async throws {
        self.session.askToBuyEnabled = true
        try await implementation.subscribe(productId)
        XCTAssert(self.session.allTransactions().count == 1)
        var transaction = self.session.allTransactions()[0]
        XCTAssert(transaction.state == .deferred)
        var hasValidSubscription = await implementation.hasValidSubscription(productId)
        XCTAssert(hasValidSubscription == false)
        
        try self.session.approveAskToBuyTransaction(identifier: transaction.identifier)
        XCTAssert(self.session.allTransactions().count == 1)
        transaction = self.session.allTransactions()[0]
        XCTAssert(transaction.state == .purchased)
        hasValidSubscription = await implementation.hasValidSubscription(productId)
        XCTAssert(hasValidSubscription == true)
    }
}
