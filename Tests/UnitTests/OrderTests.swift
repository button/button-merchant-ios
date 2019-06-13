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
        let date = Date()
        let lineItem = [Order.LineItem()]
        
        let order = Order(id: "order-abc",
                          currencyCode: "USD",
                          purchaseDate: date,
                          customerOrderId: nil,
                          lineItems: lineItem,
                          customer: nil)
        
        XCTAssertEqual(order.id, "order-abc")
        XCTAssertEqual(order.currencyCode, "USD")
        XCTAssertEqual(order.purchaseDate, date)
        XCTAssertEqual(order.lineItems, lineItem)
        XCTAssertNil(order.customerOrderId)
        XCTAssertNil(order.customer)
    }
    
    func testInitialization_allProperties() {
        let id = "order-abc"
        let currency = "USD"
        let date = Date()
        let customerOrderId = "123"
        let lineItem = [Order.LineItem()]
        let customerId = "123"
        let customer = Order.Customer()
        
        let order = Order(id: id,
                          currencyCode: currency,
                          purchaseDate: date,
                          customerOrderId: customerOrderId,
                          lineItems: lineItem,
                          customer: customer)
        
        XCTAssertEqual(order.id, id)
        XCTAssertEqual(order.currencyCode, currency)
        XCTAssertEqual(order.purchaseDate, date)
        XCTAssertEqual(order.customerOrderId, customerOrderId)
        XCTAssertEqual(order.lineItems, lineItem)
        XCTAssertEqual(order.customer, customer)
    }
    
    func testDeprecatedInit_requiredProperties() {
        let id = "order-abc"
        let amount: Int64 = 99
        let currency = "USD"
        
        let order  = Order(id: id, amount: amount, currencyCode: currency)
        
        XCTAssertEqual(order.id, id)
        XCTAssertEqual(order.amount, amount)
        XCTAssertEqual(order.currencyCode, currency)
        XCTAssertNil(order.customerOrderId)
        XCTAssertNil(order.customer)
        XCTAssertNil(order.lineItems)
        XCTAssertNil(order.purchaseDate)
    }

}
