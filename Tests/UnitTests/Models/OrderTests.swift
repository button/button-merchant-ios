//
// OrderTests.swift
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

class OrderTests: XCTestCase {

    let expectedOrderDictionary: [String: AnyHashable] = ["order_id": "derp123",
                                                          "amount": Int64(499),
                                                          "currency_code": "USD"]

    func testInitializatingAllValues() {
        // Arrange
        let expectedId = "derp-123"
        let expectedAmount: Int64 = 499
        let expectedCurrency = "USD"

        // Act
        let order = Order(id: expectedId, amount: expectedAmount, currencyCode: expectedCurrency)
        let actualId = order.id
        let actualAmount = order.amount
        let actualCurrency = order.currencyCode

        // Assert
        XCTAssertEqual(expectedId, actualId)
        XCTAssertEqual(expectedAmount, actualAmount)
        XCTAssertEqual(expectedCurrency, actualCurrency)
    }

    func testInitializingRequiredValues() {
        // Arrange
        let expectedId = "derp-abc"
        let expectedCurrency = "USD"

        // Act
        let order = Order(id: expectedId, amount: nil)
        let actualId = order.id
        let actualAmount = order.amount
        let actualCurrency = order.currencyCode

        // Assert
        XCTAssertEqual(expectedId, actualId)
        XCTAssertNil(actualAmount)
        XCTAssertEqual(expectedCurrency, actualCurrency)
    }

    func testDictionaryRepresentationIsCorrect() {
        // Arrange
        let order = Order(id: "derp123", amount: Int64(499))

        // Act
        guard let actualOrderDictionary = order.dictionaryRepresentation as? [String: AnyHashable] else {
            XCTFail("malformed dictionary")
            return
        }

        // Assert
        XCTAssertEqual(expectedOrderDictionary, actualOrderDictionary)
    }
    
}
