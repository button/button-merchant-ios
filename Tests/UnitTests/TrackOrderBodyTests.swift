//
// TrackOrderBodyTests.swift
//
// Copyright © 2018 Button, Inc. All rights reserved. (https://usebutton.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

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
        XCTAssertEqual(body.userLocalTime, "2018-01-23T12:00:00Z")
        XCTAssertEqual(body.attributionToken, "srctok-abc123")
        XCTAssertEqual(body.orderId, order.id)
        XCTAssertEqual(body.total, order.amount)
        XCTAssertEqual(body.currency, order.currencyCode)
        XCTAssertEqual(body.source, "merchant-library")
    }

    func testSerializationToDictionary() {
        let order = Order(id: "order-abc", amount: 99)
        let body = TrackOrderBody(system: TestSystem(),
                                  applicationId: "app-abc123",
                                  attributionToken: "srctok-abc123",
                                  order: order)
        XCTAssertEqual(body.dictionaryRepresentation as NSDictionary,
                       ["app_id": "app-abc123",
                        "user_local_time": "2018-01-23T12:00:00Z",
                        "btn_ref": "srctok-abc123",
                        "order_id": "order-abc",
                        "total": 99,
                        "currency": "USD",
                        "source": "merchant-library"])
    }
}
