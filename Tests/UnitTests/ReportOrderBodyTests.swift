//
// ReportOrderBodyTests.swift
//
// Copyright © 2019 Button, Inc. All rights reserved. (https://usebutton.com)
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

class ReportOrderBodyTests: XCTestCase {
    
    func testInitialization() {
        // Arrange
        let date = Date()
        let customer = Order.Customer(id: "customer-id-123")
        customer.email = "test@button.com"
        let lineItems = [Order.LineItem(id: "unique-id-1234", total: 120)]
        let order = Order(id: "order-abc", purchaseDate: date, lineItems: lineItems)
        
        // Act
        let body = ReportOrderBody(system: TestSystem(),
                                  attributionToken: "srctok-abc123",
                                  order: order)
        
        // Assert
        XCTAssertEqual(body.attributionToken, "srctok-abc123")
        XCTAssertEqual(body.orderId, order.id)
        XCTAssertEqual(body.currency, order.currencyCode)
        XCTAssertEqual(body.purchaseDate, order.purchaseDate)
        XCTAssertEqual(body.customerOrderId, order.customerOrderId)
        XCTAssertEqual(body.lineItems, body.lineItems)
        XCTAssertEqual(body.customer, body.customer)
    }

    func testSerializationToDictionary() {
        // Arrange
        Date.ISO8601Formatter.timeZone = TimeZone(identifier: "UTC")
        let date: Date = Date.ISO8601Formatter.date(from: "2019-06-17T12:08:10-04:00")!
        let email = "test@button.com"
        let customer = Order.Customer(id: "customer-id-123")
        customer.email = email
        let lineItems = [Order.LineItem(id: "unique-id-1234", total: 120)]
        let order = Order(id: "order-abc", purchaseDate: date, lineItems: lineItems)
        order.customer = customer
        order.customerOrderId = "customer-order-id-123"
        
        // Act
        let body = ReportOrderBody(system: TestSystem(),
                                  attributionToken: "srctok-abc123",
                                  order: order)
        
        // Assert
        XCTAssertEqual(body.dictionaryRepresentation as NSDictionary,
                       ["btn_ref": "srctok-abc123",
                        "order_id": "order-abc",
                        "currency": "USD",
                        "purchase_date": date.ISO8601String,
                        "customer_order_id": "customer-order-id-123",
                        "line_items": [["identifier": "unique-id-1234", "quantity": 1, "total": 120]],
                        "customer": ["id": "customer-id-123", "email_sha256": "21f61e98ab4ae120e88ac6b5dd218ffb8cf3e481276b499a2e0adab80092899c"]])
    }
    
    func testAdvertisingIdSetToNil() {
        // Arrange
        Date.ISO8601Formatter.timeZone = TimeZone(identifier: "UTC")
        let date: Date = Date.ISO8601Formatter.date(from: "2019-06-17T12:08:10-04:00")!
        let order = Order(id: "order-abc", purchaseDate: date, lineItems: [])
        let testSystem = TestSystem()
        // Act
        let body = ReportOrderBody(system: testSystem,
                                   attributionToken: "srctok-abc123",
                                   order: order)
        
        // Assert
        XCTAssertEqual(body.dictionaryRepresentation as NSDictionary,
                       ["btn_ref": "srctok-abc123",
                        "order_id": "order-abc",
                        "currency": "USD",
                        "purchase_date": date.ISO8601String,
                        "line_items": []])
    }
}
