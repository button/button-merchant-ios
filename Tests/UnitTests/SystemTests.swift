//
// SystemTests.swift
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

class SystemTests: XCTestCase {
    
    var fileManager: TestFileManager!
    var calendar: TestCalendar!
    var adIdManager: TestAdIdManager!
    var device: TestDevice!
    var screen: TestScreen!
    var locale: TestLocale!
    var bundle: TestBundle!
    
    var system: System!
    
    override func setUp() {
        super.setUp()
        fileManager = TestFileManager()
        calendar = TestCalendar()
        adIdManager = TestAdIdManager()
        device = TestDevice()
        screen = TestScreen()
        locale = TestLocale()
        bundle = TestBundle()
        system = System(fileManager: fileManager,
                        calendar: calendar,
                        adIdManager: adIdManager,
                        device: device,
                        screen: screen,
                        locale: locale,
                        bundle: bundle)
    }
    
    func testInitilization() {
        XCTAssertEqualReferences(system.fileManager, fileManager)
        XCTAssertEqualReferences(system.calendar as AnyObject, calendar)
        XCTAssertEqualReferences(system.device, device)
        XCTAssertEqualReferences(system.screen, screen)
        XCTAssertEqualReferences(system.locale as AnyObject, locale)
    }
    
    func testCurrentDateReturnsNow() {
        XCTAssertEqual(system.currentDate.ISO8601String, Date().ISO8601String)
    }

    func testIsNewInstallTrueWithin12Hours() {
        // Arrange
        fileManager.testFileCreationDateString = "2018-01-23T10:00:00Z" // 10am
        calendar.testCurrentDateString = "2018-01-23T21:00:00Z" // 9pm (+11)

        // Act
        let isNewInstall = system.isNewInstall

        // Assert
        XCTAssertTrue(isNewInstall)
    }

    func testIsNewInstallFalseExactly12Hours() {
        // Arrange
        fileManager.testFileCreationDateString = "2018-01-23T10:00:00Z" // 10am
        calendar.testCurrentDateString = "2018-01-23T22:00:00Z" // 10pm (+12)

        // Act
        let isNewInstall = system.isNewInstall

        // Assert
        XCTAssertFalse(isNewInstall)
    }

    func testIsNewInstallFalseAfter12Hours() {
        // Arrange
        fileManager.testFileCreationDateString = "2018-01-23T10:00:00Z" // 10am
        calendar.testCurrentDateString = "2018-01-23T23:00:00Z" // 11pm (+13)

        // Act
        let isNewInstall = system.isNewInstall

        // Assert
        XCTAssertFalse(isNewInstall)
    }
    
    func testIsNewInstallFalseWithoutFileCreationDate() {
        // Arrange
        calendar.testCurrentDateString = "2018-01-23T23:00:00Z" // 11pm
        
        // Act
        let isNewInstall = system.isNewInstall
        
        // Assert
        XCTAssertFalse(isNewInstall)
    }
    
    func testIFADefaultValue() {
        XCTAssertTrue(system.includesIFA)
    }
    
    func testAdvertisingId_whenValid_returnsString() {
        // Arrange
        adIdManager.stubbedID = .validId
        XCTAssertEqual(system.advertisingId, "11111111-1111-1111-1111-111111111111")
        adIdManager.stubbedID = .validIdWithLeadingZeros
        XCTAssertEqual(system.advertisingId, "00000000-0011-1111-1111-111111111111")
        adIdManager.stubbedID = .validIdWithMidZeros
        XCTAssertEqual(system.advertisingId, "11111111-1000-0000-0001-111111111111")
        adIdManager.stubbedID = .validIdWithTrailingZeros
        XCTAssertEqual(system.advertisingId, "11111111-1111-1111-1111-110000000000")
    }
    
    func testAdvertisingId_whenInvalid_returnsNil() {
        // Arrange
        system.adIdManager = TestAdIdManager(.invalidId)
        
        // Act
        let advertisingId = system.advertisingId
        
        // Assert
        XCTAssertNil(advertisingId)
    }
    
    func testincludesIFASetToFalse() {
        // Arrange
        system.includesIFA = false
        
        // Act
        let advertisingId = system.advertisingId
        
        // Assert
        XCTAssertNil(advertisingId)
    }
}
