/**

 ButtonDefaultsTests.swift

 Copyright © 2018 Button, Inc. All rights reserved. (https://usebutton.com)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

*/

import XCTest
@testable import ButtonMerchant

class ButtonDefaultsTests: XCTestCase {
    
    func testInitializationInjectsDependencies() {
        let testUserDefaults = TestUserDefaults()
        let defaults = ButtonDefaults(userDefaults: testUserDefaults)
        XCTAssertEqualReferences(defaults.userDefaults, testUserDefaults)
    }
    
    func testButtonDefaultsKeys() {
        XCTAssertEqual(ButtonDefaults.Keys.attributonToken.key, "com.usebutton.attribution-token")
    }
    
    func testSetAttributionTokenPassesTokenToUserDefaultsAndSynchronizes() {
        // Arrange
        let testUserDefaults = TestUserDefaults()
        let expectedToken = "srctok-123"
        let defaults = ButtonDefaults(userDefaults: testUserDefaults)
        
        // Act
        defaults.attributionToken = expectedToken
        let actualToken = testUserDefaults.values[ButtonDefaults.Keys.attributonToken.key]
        
        //Assert
        XCTAssertEqual(expectedToken, actualToken as? String)
        XCTAssertTrue(testUserDefaults.didCallSynchronize)
    }
    
    func testSetAttributionTokenPassesNilTokenToUserDefaultsAndSynchronizes() {
        // Arrange
        let testUserDefaults = TestUserDefaults()
        let defaults = ButtonDefaults(userDefaults: testUserDefaults)
        
        // Act
        defaults.attributionToken = nil
        
        //Assert
        XCTAssertNil(testUserDefaults.testValue)
        XCTAssertTrue(testUserDefaults.didCallSynchronize)
    }
    
    func testAccessingAttributionToken() {
        // Arrange
        let testUserDefaults = TestUserDefaults()
        let expectedToken = "srctok-123"
        testUserDefaults.values[ButtonDefaults.Keys.attributonToken.key] = expectedToken
        let defaults = ButtonDefaults(userDefaults: testUserDefaults)
        
        // Act
        let actualToken = defaults.attributionToken
        
        // Assert
        XCTAssertEqual(expectedToken, actualToken)
    }
    
    func testClearAllDataDeletesPrefixedKeys() {
        // Arrange
        let testUserDefaults = TestUserDefaults()
        let expectedToken = "srctok-123"
        testUserDefaults.values[ButtonDefaults.Keys.attributonToken.key] = expectedToken
        testUserDefaults.values["com.usebutton.derp"] = expectedToken
        let defaults = ButtonDefaults(userDefaults: testUserDefaults)
        
        // Act
        defaults.clearAllData()
        
        // Assert
        XCTAssertTrue(testUserDefaults.didCallSynchronize)
        XCTAssertTrue(testUserDefaults.values.isEmpty)
    }
    
    func testClearAllDataIgnoresNonPrefixedKeys() {
        // Arrange
        let notAButtonKey = "com.apple.type"
        let expectedValue = "macintosh"
        let testUserDefaults = TestUserDefaults()
        testUserDefaults.values[notAButtonKey] = expectedValue
        let defaults = ButtonDefaults(userDefaults: testUserDefaults)

        // Act
        defaults.clearAllData()
        let actualValue = testUserDefaults.values["com.apple.type"] as? String

        // Assert
        XCTAssertEqual(actualValue, expectedValue)
    }

    func testHasFetchedPostInstallURLTrueWhenAFetchWasAlreadyMade() {
        // Arrange
        let testUserDefaults = TestUserDefaults()
        let expectedHasFetchedBoolean = true
        testUserDefaults.values[ButtonDefaults.Keys.postInstallFetchStatus.key] = expectedHasFetchedBoolean
        let defaults = ButtonDefaults(userDefaults: testUserDefaults)

        // Act
        let actualHasFetchedBoolean = defaults.hasFetchedPostInstallURL

        // Assert
        XCTAssertEqual(expectedHasFetchedBoolean, actualHasFetchedBoolean)
    }

    func testHasFetchedPostInstallURLFalseWhenAFetchWasNeverMade() {
        // Arrange
        let testUserDefaults = TestUserDefaults()
        let defaults = ButtonDefaults(userDefaults: testUserDefaults)

        // Act
        let actualHasFetchedBoolean = defaults.hasFetchedPostInstallURL

        // Assert
        XCTAssertFalse(actualHasFetchedBoolean)
    }

    func testSettingDidFetchPostInstallURLTrue() {
        // Arrange
        let testUserDefaults = TestUserDefaults()
        let defaults = ButtonDefaults(userDefaults: testUserDefaults)

        // Act
        defaults.hasFetchedPostInstallURL = true

        // Assert
        XCTAssertTrue(defaults.hasFetchedPostInstallURL)
    }

    func testSettingDidFetchPostInstallURLFalse() {
        // Arrange
        let testUserDefaults = TestUserDefaults()
        let defaults = ButtonDefaults(userDefaults: testUserDefaults)

        // Act
        defaults.hasFetchedPostInstallURL = false

        // Assert
        XCTAssertFalse(defaults.hasFetchedPostInstallURL)
    }
}
