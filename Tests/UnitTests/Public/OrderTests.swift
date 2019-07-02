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
    
    func testInitialization_requiredPropertiesOnly() {
        // Arrange
        let id = "order-abc"
        let date: Date = Date.ISO8601Formatter.date(from: "2019-06-17T12:08:10-04:00")!
        let lineItems = [Order.LineItem(identifier: "unique-id-1234", total: 400)]

        // Act
        let order = Order(id: id,
                          purchaseDate: date,
                          lineItems: lineItems)

        // Assert
        XCTAssertEqual(order.id, id)
        XCTAssertEqual(order.currencyCode, "USD")
        XCTAssertEqual(order.purchaseDate, date.ISO8601String)
        XCTAssertEqual(order.lineItems, lineItems)
        XCTAssertNil(order.customer)
        XCTAssertNil(order.customerOrderId)
    }

    func testInitialization_allProperties() {
        // Arrange
        let id = "order-abc"
        let date: Date = Date.ISO8601Formatter.date(from: "2019-06-17T12:08:10-04:00")!
        let currencyCode = "EUR"
        let lineItems = [Order.LineItem(identifier: "unique-id-1234", total: 400)]
        let customerOrderId = "123"
        let customer = Order.Customer(id: "123")

        // Act
        let order = Order(id: id,
                          purchaseDate: date,
                          lineItems: lineItems)

        order.currencyCode = currencyCode
        order.customerOrderId = customerOrderId
        order.customer = customer

        // Assert
        XCTAssertEqual(order.id, id)
        XCTAssertEqual(order.currencyCode, currencyCode)
        XCTAssertEqual(order.purchaseDate, date.ISO8601String)
        XCTAssertEqual(order.customerOrderId, customerOrderId)
        XCTAssertEqual(order.lineItems, lineItems)
        XCTAssertEqual(order.customer, customer)
    }

    func testSettingProperties_afterInitialization() {
        // Arrange
        let date: Date = Date.ISO8601Formatter.date(from: "2019-06-17T12:08:10-04:00")!
        let order = Order(id: "valid_id",
                          purchaseDate: date,
                          lineItems: [])

        XCTAssertEqual(order.id, "valid_id")
        XCTAssertNotNil(order.purchaseDate)
        XCTAssertNotNil(order.lineItems)

        let currencyCode = "EUR"
        let customerOrderId = "123"
        let customer = Order.Customer(id: "123")

        // Act
        order.currencyCode = currencyCode
        order.customerOrderId = customerOrderId
        order.customer = customer

        // Assert
        XCTAssertEqual(order.currencyCode, currencyCode)
        XCTAssertEqual(order.customerOrderId, customerOrderId)
        XCTAssertEqual(order.customer, customer)
    }

    @available(*, deprecated)
    func testDictionaryRepresentationIsCorrect_deprecatedInit() {
        // Arrange
        let id = "derp123"
        let amount: Int64 = 499
        let lineItems: [Order.LineItem] = []
        let order = Order(id: id, amount: amount)
        let date = order.purchaseDate
        let expectedOrderDictionary: [String: AnyHashable] = ["order_id": id,
                                                              "amount": amount,
                                                              "currency": "USD",
                                                              "purchase_date": date,
                                                              "line_items": lineItems]

        // Act
        let actualOrderDictionary = order.dictionaryRepresentation

        // Assert
        XCTAssertEqual(expectedOrderDictionary, actualOrderDictionary)
    }
    
    func testCustomerInitialization_requiredPropertiesOnly() {
        // Arrange
        let id = "123"

        // Act
        let customer = Order.Customer(id: id)

        // Assert
        XCTAssertEqual(customer.id, id)
        XCTAssertNil(customer.email)
    }

    func testCustomerInitialization_allProperties_plainTextEmail() {
        // Arrange
        let id = "123"
        let email = "betty@usebutton.com"
        let emailSha256 = "c399e8d0e89e9f09aa14a36392e4cb0d058ab28b16247e80eab78ea5541a20d3"

        // Act
        let customer = Order.Customer(id: id)
        customer.email = email

        // Assert
        XCTAssertEqual(customer.id, id)
        XCTAssertEqual(customer.email, emailSha256)
    }

    func testCustomerInitialization_allProperties_nonPlainTextEmail() {
        // Arrange
        let id = "123"
        let emailSha256 = "c399e8d0e89e9f09aa14a36392e4cb0d058ab28b16247e80eab78ea5541a20d3"

        // Act
        let customer = Order.Customer(id: id)
        customer.email = emailSha256

        // Assert
        XCTAssertEqual(customer.id, id)
        XCTAssertEqual(customer.email, emailSha256)
    }

    func testLineItemInitialization_requiredPropertiesOnly() {
        // Arrange
        let identifier = "unique-id-123"
        let total: Int64 = 4000

        // Act
        let lineItem = Order.LineItem(identifier: identifier, total: total)

        // Assert
        XCTAssertEqual(lineItem.identifier, identifier)
        XCTAssertEqual(lineItem.total, total)
        XCTAssertEqual(lineItem.quantity, 1)
        XCTAssertNil(lineItem.itemDescription)
        XCTAssertNil(lineItem.sku)
        XCTAssertNil(lineItem.upc)
        XCTAssertNil(lineItem.category)
        XCTAssertNil(lineItem.attributes)
    }

    func testLineItemInitialization_allProperties() {
        // Arrange
        let identifier = "unique-id-123"
        let total: Int64 = 4000
        let quantity = 2
        let itemDescription = "laptop"
        let sku = "1234"
        let upc = "0987654321"
        let category = ["Electronics", "Computers"]
        let attributes = ["Model": "MacBook Pro"]

        // Act
        let lineItem = Order.LineItem(identifier: identifier,
                                       total: total)
        lineItem.quantity = quantity
        lineItem.itemDescription = itemDescription
        lineItem.sku = sku
        lineItem.upc = upc
        lineItem.category = category
        lineItem.attributes = attributes

        // Assert
        XCTAssertEqual(lineItem.identifier, identifier)
        XCTAssertEqual(lineItem.total, total)
        XCTAssertEqual(lineItem.quantity, quantity)
        XCTAssertEqual(lineItem.itemDescription, itemDescription)
        XCTAssertEqual(lineItem.sku, sku)
        XCTAssertEqual(lineItem.upc, upc)
        XCTAssertEqual(lineItem.category, category)
        XCTAssertEqual(lineItem.attributes, attributes)
    }

}
