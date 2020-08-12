//
// ActivityRequestBodyTests.swift
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

class ActivityRequestBodyTests: XCTestCase {
    
    func testInitialization_createsInstance() {
        let product = ButtonProduct()
        product.id = "some id"
        let body = ActivityRequestBody(ifa: "some ifa", attributionToken: "some srctok", name: "some name", products: [product])
        XCTAssertNotNil(body)
        XCTAssertEqual(body.ifa, "some ifa")
        XCTAssertEqual(body.name, "some name")
        XCTAssertEqual(body.products?.first?.id, "some id")
    }
    
    func testDictionaryRepresentation_noIFA() {
        let body = ActivityRequestBody(ifa: nil, attributionToken: nil, name: "some name", products: nil)
        XCTAssertEqual(body.dictionaryRepresentation as NSDictionary, ["name": "some name"])
    }
    
    func testDictionaryRepresentation_withIFA() {
        let body = ActivityRequestBody(ifa: "some ifa", attributionToken: nil, name: "some name", products: nil)
        XCTAssertEqual(body.dictionaryRepresentation as NSDictionary, ["name": "some name", "ifa": "some ifa"])
    }
    
    func testDictionaryRepresentation_withAttributionToken() {
        let body = ActivityRequestBody(ifa: nil, attributionToken: "some srctok", name: "some name", products: nil)
        XCTAssertEqual(body.dictionaryRepresentation as NSDictionary, ["name": "some name", "btn_ref": "some srctok"])
    }
    
    func testDictionaryRepresentation_emptyProducts() {
        let body = ActivityRequestBody(ifa: "some ifa", attributionToken: nil, name: "some name", products: [ButtonProduct(), ButtonProduct()])
        XCTAssertEqual(body.dictionaryRepresentation as NSDictionary,
                       [
                        "name": "some name",
                        "ifa": "some ifa",
                        "products": [[:], [:]]]
        )
    }

    func testDictionaryRepresentation_withProduct() {
        let product = ButtonProduct()
        product.id = "some id"
        product.upc = "some upc"
        product.categories = ["abc", "xyz"]
        product.name = "some name"
        product.currency = "USD"
        product.value = 7
        product.quantity = 25
        product.url = "example.com"
        product.attributes = ["a": "z", "b": "y"]
        let body = ActivityRequestBody(ifa: "some ifa", attributionToken: nil, name: "some name", products: [product])
        XCTAssertEqual(body.dictionaryRepresentation as NSDictionary,
                       [
                        "name": "some name",
                        "ifa": "some ifa",
                        "products": [[
                            "id": "some id",
                            "upc": "some upc",
                            "categories": ["abc", "xyz"],
                            "name": "some name",
                            "currency": "USD",
                            "value": 7,
                            "quantity": 25,
                            "url": "example.com",
                            "attributes": [
                                "a": "z",
                                "b": "y"
                            ]]]]
        )
    }
}
