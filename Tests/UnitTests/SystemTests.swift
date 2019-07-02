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

    func testInitilization() {
        let fileManager = TestFileManager()
        let calendar = TestCalendar()
        let adIdManager = TestAdIdManager()
        let device = TestDevice()
        let screen = TestScreen()
        let locale = TestLocale()
        let bundle = TestBundle()
        let system = System(fileManager: fileManager,
                             calendar: calendar,
                             adIdManager: adIdManager,
                             device: device,
                             screen: screen,
                             locale: locale,
                             bundle: bundle)
        XCTAssertEqualReferences(system.fileManager, fileManager)
        XCTAssertEqualReferences(system.calendar as AnyObject, calendar)
        //XCTAssertEqualReferences(system.adIdManager, adIdManager)
        XCTAssertEqualReferences(system.device, device)
        XCTAssertEqualReferences(system.screen, screen)
        XCTAssertEqualReferences(system.locale as AnyObject, locale)
    }

    func testCurrentDateReturnsNow() {
        let system = System(fileManager: TestFileManager(),
                            calendar: TestCalendar(),
                            adIdManager: TestAdIdManager(),
                            device: TestDevice(),
                            screen: TestScreen(),
                            locale: TestLocale(),
                            bundle: TestBundle())
        XCTAssertEqual(system.currentDate.ISO8601String, Date().ISO8601String)
    }

    func testIsNewInstallTrueWithin12Hours() {
        // Arrange
        let testFileManager = TestFileManager()
        let testCalendar = TestCalendar()
        testFileManager.testFileCreationDateString = "2018-01-23T10:00:00Z" // 10am
        testCalendar.testCurrentDateString = "2018-01-23T21:00:00Z" // 9pm (+11)
        let system = System(fileManager: testFileManager,
                            calendar: testCalendar,
                            adIdManager: TestAdIdManager(),
                            device: TestDevice(),
                            screen: TestScreen(),
                            locale: TestLocale(),
                            bundle: TestBundle())

        // Act
        let isNewInstall = system.isNewInstall

        // Assert
        XCTAssertTrue(isNewInstall)
    }

    func testIsNewInstallFalseExactly12Hours() {
        // Arrange
        let testFileManager = TestFileManager()
        let testCalendar = TestCalendar()
        testFileManager.testFileCreationDateString = "2018-01-23T10:00:00Z" // 10am
        testCalendar.testCurrentDateString = "2018-01-23T22:00:00Z" // 10pm (+12)
        let system = System(fileManager: testFileManager,
                            calendar: testCalendar,
                            adIdManager: TestAdIdManager(),
                            device: TestDevice(),
                            screen: TestScreen(),
                            locale: TestLocale(),
                            bundle: TestBundle())

        // Act
        let isNewInstall = system.isNewInstall

        // Assert
        XCTAssertFalse(isNewInstall)
    }

    func testIsNewInstallFalseAfter12Hours() {
        // Arrange
        let testFileManager = TestFileManager()
        let testCalendar = TestCalendar()
        testFileManager.testFileCreationDateString = "2018-01-23T10:00:00Z" // 10am
        testCalendar.testCurrentDateString = "2018-01-23T23:00:00Z" // 11pm (+13)
        let system = System(fileManager: testFileManager,
                            calendar: testCalendar,
                            adIdManager: TestAdIdManager(),
                            device: TestDevice(),
                            screen: TestScreen(),
                            locale: TestLocale(),
                            bundle: TestBundle())

        // Act
        let isNewInstall = system.isNewInstall

        // Assert
        XCTAssertFalse(isNewInstall)
    }
    
    func testIsNewInstallFalseWithoutFileCreationDate() {
        // Arrange
        let testFileManager = TestFileManager()
        let testCalendar = TestCalendar()
        testCalendar.testCurrentDateString = "2018-01-23T23:00:00Z" // 11pm
        let system = System(fileManager: testFileManager,
                            calendar: testCalendar,
                            adIdManager: TestAdIdManager(),
                            device: TestDevice(),
                            screen: TestScreen(),
                            locale: TestLocale(),
                            bundle: TestBundle())
        
        // Act
        let isNewInstall = system.isNewInstall
        
        // Assert
        XCTAssertFalse(isNewInstall)
    }
    
    func testIFADefaultValue() {
        let system = System(fileManager: TestFileManager(),
                            calendar: TestCalendar(),
                            adIdManager: TestAdIdManager(),
                            device: TestDevice(),
                            screen: TestScreen(),
                            locale: TestLocale(),
                            bundle: TestBundle())
        
        XCTAssertTrue(system.includesIFA)
    }
    
    func testAdvertisingIdInitialization() {
        let system = System(fileManager: TestFileManager(),
                            calendar: TestCalendar(),
                            adIdManager: TestAdIdManager(),
                            device: TestDevice(),
                            screen: TestScreen(),
                            locale: TestLocale(),
                            bundle: TestBundle())
        
        XCTAssertEqual(system.advertisingId, "00000000-0000-0000-0000-000000000000")
    }
}
