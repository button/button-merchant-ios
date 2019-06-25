//
// ButtonMerchantTests.swift
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

class ButtonMerchantTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        ButtonMerchant._core = nil
    }

    func testBuildNumber() {
        XCTAssertEqual(ButtonMerchantVersionNumber, 1)
    }

    func testConfigureApplicationId() {
        // Arrange
        let applicationId = "app-test"
        let testCore = TestCore(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                                client: TestClient(session: TestURLSession(),
                                                   userAgent: TestUserAgent(system: TestSystem())),
                                system: TestSystem(),
                                notificationCenter: TestNotificationCenter())

        // Act
        ButtonMerchant._core = testCore
        ButtonMerchant.configure(applicationId: applicationId)

        // Assert
        XCTAssertEqual(testCore.applicationId, applicationId)
    }

    func testCreateCoreCreatesCoreWhenCoreSetToNil() {
        ButtonMerchant._core = nil
        ButtonMerchant.configure(applicationId: "app-test")
        XCTAssertTrue(ButtonMerchant._core is Core)
    }

    func testTrackIncomingURLInvokesCore() {
        // Arrange
        let testCore = TestCore(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                                client: TestClient(session: TestURLSession(),
                                                   userAgent: TestUserAgent(system: TestSystem())),
                                system: TestSystem(),
                                notificationCenter: TestNotificationCenter())
        let expectedUrl = URL(string: "usebutton.com")!

        // Act
        ButtonMerchant._core = testCore
        ButtonMerchant.trackIncomingURL(expectedUrl)
        let actualUrl = testCore.testUrl

        // Assert
        XCTAssertEqual(actualUrl, expectedUrl)
    }
    
    func testTrackIncomingUserActivityInvokesCore() {
        // Arrange
        let testCore = TestCore(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                                client: TestClient(session: TestURLSession(),
                                                   userAgent: TestUserAgent(system: TestSystem())),
                                system: TestSystem(),
                                notificationCenter: TestNotificationCenter())
        let expectedUrl = URL(string: "https://usebutton.com")!
        let userActivity = NSUserActivity(activityType: "com.usebutton.web_activity")
        userActivity.webpageURL = expectedUrl
        
        // Act
        ButtonMerchant._core = testCore
        ButtonMerchant.trackIncomingUserActivity(userActivity)
        let actualUrl = testCore.testUrl
        
        // Assert
        XCTAssertEqual(actualUrl, expectedUrl)
    }

    func testAccessingAttributionToken() {
        // Arrange
        let testCore = TestCore(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                                client: TestClient(session: TestURLSession(),
                                                   userAgent: TestUserAgent(system: TestSystem())),
                                system: TestSystem(),
                                notificationCenter: TestNotificationCenter())
        testCore.testToken = "srctok-123"
        let expectedToken = testCore.testToken

        // Act
        ButtonMerchant._core = testCore

        // Assert
        XCTAssertNotNil(ButtonMerchant.attributionToken)
        XCTAssertEqual(ButtonMerchant.attributionToken, expectedToken)
    }

    func testClearAllDataInvokesCore() {
        // Arrange
        let testCore = TestCore(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                                client: TestClient(session: TestURLSession(),
                                                   userAgent: TestUserAgent(system: TestSystem())),
                                system: TestSystem(),
                                notificationCenter: TestNotificationCenter())

        // Act
        ButtonMerchant._core = testCore
        ButtonMerchant.clearAllData()

        // Assert
        XCTAssertTrue(testCore.didCallClearAllData)
    }

    func testHandlePostInstallURLInvokesCore() {
        // Arrange
        let testCore = TestCore(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                                client: TestClient(session: TestURLSession(),
                                                   userAgent: TestUserAgent(system: TestSystem())),
                                system: TestSystem(),
                                notificationCenter: TestNotificationCenter())

        // Act
        ButtonMerchant._core = testCore
        ButtonMerchant.handlePostInstallURL { _, _  in }

        XCTAssertTrue(testCore.didCallFetchPostInstallURL)
    }

    @available(*, deprecated)
    func testTrackOrderInvokesCoreWithOrder() {
        // Arrange
        let testSystem = TestSystem()
        let testCore = TestCore(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                                client: TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: testSystem)),
                                system: testSystem,
                                notificationCenter: TestNotificationCenter())
        let expectedOrder = Order(id: "test", amount: Int64(12))

        // Act
        ButtonMerchant._core = testCore
        ButtonMerchant.trackOrder(expectedOrder) { _ in }

        // Assert
        XCTAssertEqual(testCore.testOrder, expectedOrder)
    }
    
    func testReportOrderInvokesCoreWithOrder() {
        // Arrange
        let testSystem = TestSystem()
        let testCore = TestCore(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                                client: TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: testSystem)),
                                system: testSystem,
                                notificationCenter: TestNotificationCenter())
        let expectedOrder = Order(id: "test",
                                  purchaseDate: Date(),
                                  lineItems: [Order.LineItem(identifier: "unique-id-1234", total: 400)])
        
        // Act
        ButtonMerchant._core = testCore
        ButtonMerchant.reportOrder(expectedOrder) { _ in }
        
        // Assert
        XCTAssertEqual(testCore.testOrder, expectedOrder)
    }
}
