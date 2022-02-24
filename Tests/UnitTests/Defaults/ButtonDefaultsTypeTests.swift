//
// ButtonDefaultsTests.swift
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
import Core
@testable import ButtonMerchant

class ButtonDefaultsTypeTests: XCTestCase {
    
    var userDefaults: TestUserDefaults!
    var defaults: ButtonDefaultsType!

    override func setUp() {
        userDefaults = TestUserDefaults()
        defaults = Defaults(userDefaults: userDefaults)
    }
    
    func testKeys() {
        XCTAssertEqual(Defaults.Button.Key.attributonToken.prefixed.rawValue, "com.usebutton.attribution-token")
        XCTAssertEqual(Defaults.Button.Key.postInstallFetchStatus.prefixed.rawValue, "com.usebutton.post-install-fetched")
    }

    func testSetAttributionTokenSynchronizes() {
        defaults.attributionToken = "srctok-test"
        XCTAssertEqual(defaults.attributionToken, "srctok-test")
        XCTAssertEqual(userDefaults.values["com.usebutton.attribution-token"] as? String, "srctok-test")
        XCTAssertTrue(userDefaults.didCallSynchronize)
    }

    func testSetAttributionTokenNilSynchronizes() {
        userDefaults.values["com.usebutton.attribution-token"] = "srctok-test"
        XCTAssertEqual(defaults.attributionToken, "srctok-test")
        defaults.attributionToken = nil
        XCTAssertNil(defaults.attributionToken)
        XCTAssertTrue(userDefaults.values.isEmpty)
        XCTAssertTrue(userDefaults.didCallSynchronize)
    }

    func testSetPostInstallFetchStatusSynchronizes() {
        XCTAssertFalse(defaults.hasFetchedPostInstallURL)
        defaults.hasFetchedPostInstallURL = true
        XCTAssertTrue(defaults.hasFetchedPostInstallURL)
        XCTAssertTrue(userDefaults.values["com.usebutton.post-install-fetched"] as! Bool)
        XCTAssertTrue(userDefaults.didCallSynchronize)
    }
}
