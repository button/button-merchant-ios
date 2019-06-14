//
// OrderTests.swift
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

class OrderTests: XCTestCase {
    
    func testInitialization_requiredProperties() {
        let id = "order-abc"
        let currencyCode = "EUR"
        let date = Date()
        let lineItems = [Order.LineItem()]
        
        let order = Order(id: id,
                          currencyCode: currencyCode,
                          purchaseDate: date,
                          lineItems: lineItems)
        
        XCTAssertEqual(order.id, id)
        XCTAssertEqual(order.currencyCode, currencyCode)
        XCTAssertEqual(order.purchaseDate, date)
        XCTAssertEqual(order.lineItems, lineItems)
        XCTAssertNil(order.customerOrderId)
        XCTAssertNil(order.customer)
    }

    func testInitialization_defaultCurrency() {
        let id = "order-abc"
        let date = Date()
        let lineItems = [Order.LineItem()]

        let order = Order(id: id,
                          purchaseDate: date,
                          lineItems: lineItems)

        XCTAssertEqual(order.id, id)
        XCTAssertEqual(order.currencyCode, "USD")
        XCTAssertEqual(order.purchaseDate, date)
        XCTAssertEqual(order.lineItems, lineItems)
        XCTAssertNil(order.customerOrderId)
        XCTAssertNil(order.customer)
    }

    func testInitialization_allProperties() {
        let id = "order-abc"
        let currencyCode = "USD"
        let date = Date()
        let lineItems = [Order.LineItem()]
        let customerOrderId = "123"
        let customer = Order.Customer()
        
        let order = Order(id: id,
                          currencyCode: currencyCode,
                          purchaseDate: date,
                          lineItems: lineItems)

        order.customerOrderId = customerOrderId
        order.customer = customer
        
        XCTAssertEqual(order.id, id)
        XCTAssertEqual(order.currencyCode, currencyCode)
        XCTAssertEqual(order.purchaseDate, date)
        XCTAssertEqual(order.customerOrderId, customerOrderId)
        XCTAssertEqual(order.lineItems, lineItems)
        XCTAssertEqual(order.customer, customer)
    }

    func testSettingProperties_afterInitialization() {
        let order = Order(id: "valid_id",
                          purchaseDate: Date(),
                          lineItems: [])

        XCTAssertEqual(order.id, "valid_id")
        XCTAssertNotNil(order.purchaseDate)
        XCTAssertNotNil(order.lineItems)

        let id = "order-abc"
        let currencyCode = "EUR"
        let date = Date()
        let lineItems = [Order.LineItem()]
        let customerOrderId = "123"
        let customer = Order.Customer()

        order.id = id
        order.currencyCode = currencyCode
        order.purchaseDate = date
        order.lineItems = lineItems
        order.customerOrderId = customerOrderId
        order.customer = customer

        XCTAssertEqual(order.id, id)
        XCTAssertEqual(order.currencyCode, currencyCode)
        XCTAssertEqual(order.purchaseDate, date)
        XCTAssertEqual(order.customerOrderId, customerOrderId)
        XCTAssertEqual(order.lineItems, lineItems)
        XCTAssertEqual(order.customer, customer)
    }

    @available(*, deprecated)
    func testDictionaryRepresentationIsCorrect_deprecatedInit() {
        // Arrange
        let id = "derp123"
        let amount: Int64 = 499
        let expectedOrderDictionary: [String: AnyHashable] = ["order_id": id,
                                                              "amount": amount,
                                                              "currency": "USD"]
        let order = Order(id: id, amount: amount)

        // Act
        guard let actualOrderDictionary = order.dictionaryRepresentation as? [String: AnyHashable] else {
            XCTFail("malformed dictionary")
            return
        }

        // Assert
        XCTAssertEqual(expectedOrderDictionary, actualOrderDictionary)
    }

}
