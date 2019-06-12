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
    
    func testInitialization() {
        let order = Order(id: "order-abc",
                          amount: 99,
                          currencyCode: "USD",
                          purchaseDate: nil,
                          sourceToken: nil,
                          customerOrderId: nil,
                          lineItems: nil,
                          customer: nil)
        XCTAssertEqual(order.id, "order-abc")
        XCTAssertEqual(order.amount, 99)
        XCTAssertEqual(order.currencyCode, "USD")
        XCTAssertEqual(order.purchaseDate, nil)
        XCTAssertEqual(order.sourceToken, nil)
        XCTAssertEqual(order.lineItems, nil)
        XCTAssertEqual(order.customer, nil)
    }
    
    func testAmountInitialization() {
        let amount: Int64 = 99
        
        let order = Order(id: "order-abc", amount: amount, currencyCode: "USD", purchaseDate: nil)
        XCTAssertEqual(order.amount, amount)
    }
    
    func testCurrencyCodeInitialization() {
        let currency = "USD"
        
        let order = Order(id: "order-abc", amount: 99, currencyCode: currency, purchaseDate: nil)
        XCTAssertEqual(order.currencyCode, currency)
    }
    
    func testDateInitialization() {
        let date = Date()
        
        let order = Order(id: "order-abc", purchaseDate: date)
        XCTAssertEqual(order.purchaseDate, date)
    }
    
    func testSourceTokenInitialization() {
        let token = "valid_source_token"
        
        let order = Order(id: "order-abc", sourceToken: token)
        XCTAssertEqual(order.sourceToken, token)
    }
    
    func testCustomerOrderIdInitialization() {
        let customerOrderId = "123"
        
        let order = Order(id: "order-abc", customerOrderId: customerOrderId)
        XCTAssertEqual(order.customerOrderId, customerOrderId)
    }
    
    func testLineItemsInitialization() {
        let lineItem = [Order.LineItems]()
        
        let order = Order(id: "order-abc", lineItems: lineItem)
        XCTAssertEqual(order.lineItems, lineItem)
    }
    
    func testCustomerInitialization() {
        let customer = Order.Customer()
        let order = Order(id: "order-abc", customer: customer)
        XCTAssertEqual(order.customer, customer)
    }
    
    func testAllParametersWhenInitializing() {
        let id = "order-abc"
        let amount: Int64 = 99
        let currency = "USD"
        let date = Date()
        let token = "valid_source_token"
        let customerOrderId = "123"
        let lineItem = [Order.LineItems]()
        let customer = Order.Customer()
        
        let order = Order(id: id,
                          amount: amount,
                          currencyCode: currency,
                          purchaseDate: date,
                          sourceToken: token,
                          customerOrderId: customerOrderId,
                          lineItems: lineItem,
                          customer: customer)
        XCTAssertEqual(order.id, id)
        XCTAssertEqual(order.amount, amount)
        XCTAssertEqual(order.currencyCode, currency)
        XCTAssertEqual(order.purchaseDate, date)
        XCTAssertEqual(order.sourceToken, token)
        XCTAssertEqual(order.customerOrderId, customerOrderId)
        XCTAssertEqual(order.lineItems, lineItem)
        XCTAssertEqual(order.customer, customer)
    }
    
    func testDeprecatedInit() {
        let id = "order-abc"
        let amount: Int64 = 99
        let currency = "USD"
        
        let order  = Order(id: id, amount: amount, currencyCode: currency)
        XCTAssertEqual(order.id, id)
        XCTAssertEqual(order.amount, amount)
        XCTAssertEqual(order.currencyCode, currency)
        XCTAssertEqual(order.purchaseDate, nil)
        XCTAssertEqual(order.sourceToken, nil)
        XCTAssertEqual(order.customerOrderId, nil)
        XCTAssertEqual(order.lineItems, nil)
        XCTAssertEqual(order.customer, nil)
    }
    
    func testDeprecatedInitOnlyId() {
        let id = "order-abc"
        
        let order = Order(id: id)
        XCTAssertEqual(order.id, id)
        XCTAssertEqual(order.amount, 0)
        XCTAssertEqual(order.currencyCode, "currency")
        XCTAssertEqual(order.purchaseDate, nil)
        XCTAssertEqual(order.sourceToken, nil)
        XCTAssertEqual(order.customerOrderId, nil)
        XCTAssertEqual(order.lineItems, nil)
        XCTAssertEqual(order.customer, nil)
    }
    
}
