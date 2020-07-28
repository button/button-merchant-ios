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

    var testCore: TestCore!
    
    override func setUp() {
        let defaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        testCore = TestCore(buttonDefaults: defaults,
                            client: TestClient(session: TestURLSession(),
                                               userAgent: TestUserAgent(system: TestSystem()),
                                               defaults: defaults),
                            system: TestSystem(),
                            notificationCenter: TestNotificationCenter())
    }
    
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
        ButtonMerchant._core = testCore
        
        // Act
        ButtonMerchant.configure(applicationId: applicationId)

        // Assert
        XCTAssertEqual(testCore.applicationId, applicationId)
    }

    func testCreateCoreCreatesCoreWhenCoreSetToNil() {
        // Arrange
        ButtonMerchant._core = nil
        
        // Act
        ButtonMerchant.configure(applicationId: "app-test")
        
        // Assert
        XCTAssertTrue(ButtonMerchant._core is Core)
    }

    func testTrackIncomingURLInvokesCore() {
        // Arrange
        let expectedUrl = URL(string: "usebutton.com")!
        ButtonMerchant._core = testCore
        
        // Act
        ButtonMerchant.trackIncomingURL(expectedUrl)
        let actualUrl = testCore.testUrl

        // Assert
        XCTAssertEqual(actualUrl, expectedUrl)
    }
    
    func testTrackIncomingUserActivityInvokesCore() {
        // Arrange
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
        ButtonMerchant._core = testCore
        
        // Act
        ButtonMerchant.clearAllData()

        // Assert
        XCTAssertTrue(testCore.didCallClearAllData)
    }

    func testHandlePostInstallURLInvokesCore() {
        // Arrange
        ButtonMerchant._core = testCore
        
        // Act
        ButtonMerchant.handlePostInstallURL { _, _  in }

        // Assert
        XCTAssertTrue(testCore.didCallFetchPostInstallURL)
    }

    @available(*, deprecated)
    func testTrackOrderInvokesCoreWithOrder() {
        let expectation = self.expectation(description: "trackOrder deprecation error")
        
        // Arrange
        ButtonMerchant._core = testCore
        
        // Act
        ButtonMerchant.trackOrder(Order(id: "test", amount: Int64(12))) { error in
            
            // Assert
            XCTAssertEqual(error as? String,
                           "trackOrder(_:) is No longer supported. You can safely remove your usage of this method.")
            
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportOrderInvokesCoreWithOrder() {
        // Arrange
        let expectedOrder = Order(id: "test",
                                  purchaseDate: Date(),
                                  lineItems: [Order.LineItem(id: "unique-id-1234", total: 400)])
        ButtonMerchant._core = testCore
        
        // Act
        ButtonMerchant.reportOrder(expectedOrder) { _ in }
        
        // Assert
        XCTAssertEqual(testCore.testOrder, expectedOrder)
    }
    
    func testIFASetFalse() {
        // Arrange
        ButtonMerchant._core = testCore
        
        // Act
        ButtonMerchant.features.includesIFA = false
        
        // Assert
        XCTAssertFalse(ButtonMerchant.features.includesIFA)
    }
    
    func testIFASetTrue() {
        // Arrange
        ButtonMerchant._core = testCore
        
        // Act
        ButtonMerchant.features.includesIFA = true
        
        // Assert
        XCTAssertTrue(ButtonMerchant.features.includesIFA)
    }
}
