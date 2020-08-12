//
// AppEventTests.swift
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

class AppEventTests: XCTestCase {

    func testInitialization_createsInstance() {
        let event = AppEvent(name: "test event", value: ["foo": "bar"], attributionToken: "some token", time: "some time", uuid: "some uuid")
        XCTAssertEqual(event.name, "test event")
        XCTAssertEqual(event.value, ["foo": "bar"])
        XCTAssertEqual(event.attributionToken, "some token")
        XCTAssertEqual(event.time, "some time")
        XCTAssertEqual(event.uuid, "some uuid")
    }
    
    func testSerialization_createsDictionary() {
        let event = AppEvent(name: "test event", value: ["foo": "bar"], attributionToken: "some token", time: "some time", uuid: "some uuid")
        XCTAssertEqual(event.dictionaryRepresentation as NSDictionary, [
            "name": "test event",
            "value": ["foo": "bar"],
            "promotion_source_token": "some token",
            "time": "some time",
            "uuid": "some uuid"
        ])
    }
    
    func testMissingValue_omitsValue() {
        let event = AppEvent(name: "test event", value: nil, attributionToken: "some token", time: "some time", uuid: "some uuid")
        XCTAssertEqual(event.dictionaryRepresentation as NSDictionary, [
            "name": "test event",
            "promotion_source_token": "some token",
            "time": "some time",
            "uuid": "some uuid"
        ])
    }
    
    func testMissingSourceToken_omitsSourceToken() {
        let event = AppEvent(name: "test event", value: ["foo": "bar"], attributionToken: nil, time: "some time", uuid: "some uuid")
        XCTAssertEqual(event.dictionaryRepresentation as NSDictionary, [
            "name": "test event",
            "value": ["foo": "bar"],
            "time": "some time",
            "uuid": "some uuid"
        ])
    }
}
