//
// AppEventRequestBodyTests.swift
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

class AppEventsRequestBodyTests: XCTestCase {
    
    func testInitialization_createsInstance() {
        let event = AppEvent(name: "test-event",
                             value: ["url": "https://example.com"],
                             sourceToken: "some token")
        let body = AppEventsRequestBody(ifa: "some ifa", events: [event])
        
        XCTAssertEqual(body.ifa, "some ifa")
        XCTAssertEqual(body.events.count, 1)
        XCTAssertEqual(body.events.first?.name, "test-event")
        XCTAssertEqual(body.events.first?.value, ["url": "https://example.com"])
        XCTAssertEqual(body.events.first?.sourceToken, "some token")
    }
    
    func testSerialization_createsDisctionary() {
        let event = AppEvent(name: "test-event",
                             value: ["url": "https://example.com"],
                             sourceToken: "some token")
        let body = AppEventsRequestBody(ifa: "some ifa", events: [event])
        
        XCTAssertEqual(body.dictionaryRepresentation as NSDictionary,
                       [
                        "ifa": "some ifa",
                        "events": [
                            [
                                "name": "test-event",
                                "value": ["url": "https://example.com"],
                                "promotion_source_token": "some token"
                            ]
                        ]])
    }
    
    func testMissingIFA_omitsIFA() {
        let event = AppEvent(name: "test-event",
                             value: ["url": "https://example.com"],
                             sourceToken: "some token")
        let body = AppEventsRequestBody(ifa: nil, events: [event])
        
        XCTAssertEqual(body.dictionaryRepresentation as NSDictionary,
                       [
                        "events": [
                            [
                                "name": "test-event",
                                "value": ["url": "https://example.com"],
                                "promotion_source_token": "some token"
                            ]
                        ]])
    }
}
