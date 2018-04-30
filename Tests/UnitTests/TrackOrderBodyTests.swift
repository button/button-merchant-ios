import XCTest
@testable import ButtonMerchant

class TrackOrderBodyTests: XCTestCase {

    func testInitialization() {
        let order = Order(id: "order-abc", amount: 99)
        let body = TrackOrderBody(system: TestSystem(),
                                            applicationId: "app-abc123",
                                            attributionToken: "srctok-abc123",
                                            order: order)
        XCTAssertEqual(body.applicationId, "app-abc123")
        XCTAssertEqual(body.attributionToken, "srctok-abc123")
        XCTAssertEqual(body.device.ifa, "00000000-0000-0000-0000-000000000000")
        XCTAssertFalse(body.device.ifaLimited)
        XCTAssertEqual(body.userLocalTime, "2018-01-23T12:00:00Z")
        XCTAssertEqual(body.type, "order-checkout")
        XCTAssertEqualReferences(body.order, order)
    }

    func testSerializationToDictionary() {
        let order = Order(id: "order-abc", amount: 99)
        let body = TrackOrderBody(system: TestSystem(),
                                  applicationId: "app-abc123",
                                  attributionToken: "srctok-abc123",
                                  order: order)
        XCTAssertEqual(body.dictionaryRepresentation as NSDictionary,
                       ["app_id": "app-abc123",
                        "btn_ref": "srctok-abc123",
                        "user_local_time": "2018-01-23T12:00:00Z",
                        "type": "order-checkout",
                        "device": ["ifa": "00000000-0000-0000-0000-000000000000",
                                   "ifa_limited": false],
                        "order": ["order_id": "order-abc",
                                  "amount": 99,
                                  "currency_code": "USD" ]])
    }
}
