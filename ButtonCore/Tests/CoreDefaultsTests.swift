//
// CoreDefaultsTests.swift
//
// Copyright © 2022 Button, Inc. All rights reserved. (https://usebutton.com)
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
@testable import Core

class CoreDefaultsTypeTests: XCTestCase {

    var userDefaults: TestUserDefaults!
    var defaults: CoreDefaultsType!

    override func setUp() {
        userDefaults = TestUserDefaults()
        defaults = Defaults(userDefaults: userDefaults)
    }

    func testInit() {
        XCTAssertEqualReferences(defaults.userDefaults, userDefaults)
    }

    func testKeys() {
        XCTAssertEqual(Defaults.Key.sessionId.prefixed.rawValue, "com.usebutton.session-id")
    }

    func testSetSessionIdSynchronizes() {
        defaults.sessionId = "sess-test"
        XCTAssertEqual(defaults.sessionId, "sess-test")
        XCTAssertEqual(userDefaults.values["com.usebutton.session-id"] as? String, "sess-test")
        XCTAssertTrue(userDefaults.didCallSynchronize)
    }

    func testSetSessionIdNilSynchronizes() {
        userDefaults.values["com.usebutton.session-id"] = "sess-test"
        XCTAssertEqual(defaults.sessionId, "sess-test")
        defaults.sessionId = nil
        XCTAssertNil(defaults.sessionId)
        XCTAssertTrue(userDefaults.values.isEmpty)
        XCTAssertTrue(userDefaults.didCallSynchronize)
    }

    func testSetValueForKeySetsValueAndSyncronizes() {
        defaults.set("test-value", for: Defaults.PrefixedKey(rawValue: "test-key"))
        XCTAssertEqual(userDefaults.values["com.usebutton.test-key"] as? String, "test-value")
        XCTAssertTrue(userDefaults.didCallSynchronize)
    }

    func testValueForKeyReturnsValue() {
        userDefaults.values["com.usebutton.test-key"] = "test-value"
        XCTAssertEqual(defaults.value(for: Defaults.PrefixedKey(rawValue: "test-key")) as? String, "test-value")
    }

    func testClearAllDataDeletesPrefixedKeysOnly() {
        // Arrange
        defaults.sessionId = "sess-abc123"
        userDefaults.values = [
            "non-prefixed-key": "test-value",
            "com.usebutton.test-value1": "test-key1",
            "com.usebutton.test-value2": "test-key2"
        ]

        // Act
        defaults.clearAllData()

        // Assert
        XCTAssertTrue(userDefaults.didCallSynchronize)
        XCTAssertEqual(userDefaults.values.count, 1)
        XCTAssertEqual(userDefaults.values["non-prefixed-key"] as? String, "test-value")
    }
}
