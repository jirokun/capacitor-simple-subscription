import XCTest
@testable import Plugin

class SubscriptionManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetSubscription() async {
        let implementation = SubscriptionManager()
        let productId = "TEGAKI_SANSU_UNLOCK"
        let result = await implementation.getSubscription(productId)
        let actual: String = result!["productId"] as! String

        XCTAssertEqual(actual, productId)
    }
}
