//
// ButtonProductTests.swift
//
// Copyright © 2020 Button, Inc. All rights reserved. (https://usebutton.com)
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

extension ButtonProduct {
    static func stub() -> ButtonProductCompatible {
        let product = ButtonProduct()
        product.id = "prod-test"
        product.upc = "upc-test"
        product.name = "test-product"
        product.value = 100
        product.quantity = 1
        product.url = "https://example.com/1"
        product.attributes = [ "foo": "bar" ]
        return product
    }
}

class ButtonProductTests: XCTestCase {
    
    func testInitialization_createsInstance() {
        let product = ButtonProduct()
        XCTAssertNotNil(product)
        XCTAssertNil(product.id)
        XCTAssertNil(product.upc)
        XCTAssertNil(product.categories)
        XCTAssertNil(product.name)
        XCTAssertNil(product.currency)
        XCTAssertNil(product.url)
        XCTAssertNil(product.attributes)
        XCTAssertEqual(product.value, 0)
        XCTAssertEqual(product.quantity, 0)
    }
}
