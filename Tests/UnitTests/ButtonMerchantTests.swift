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
    
    var testInstance: TestInternal!
    
    override func setUp() {
        let defaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        testInstance = TestInternal(defaults: defaults,
                                    client: TestClient(defaults: defaults,
                                                       system: TestSystem(),
                                                       network: TestNetwork()),
                                    system: TestSystem(),
                                    notificationCenter: TestNotificationCenter(),
                                    verifier: TestAppIntegrationVerification(application: TestApplication(),
                                                                             defaults: defaults))
    }
    
    override func tearDown() {
        super.tearDown()
        ButtonMerchant._instance = nil
    }

    func testBuildNumber() {
        XCTAssertEqual(ButtonMerchantVersionNumber, 1)
    }

    func testConfigureApplicationId() {
        // Arrange
        let applicationId = "app-test"
        ButtonMerchant._instance = testInstance

        // Act
        ButtonMerchant.configure(applicationId: applicationId)

        // Assert
        XCTAssertEqual(testInstance.applicationId?.rawValue, applicationId)
    }
    
    func testConfigureCreatesInstanceWhenNil() {
        // Arrange
        ButtonMerchant._instance = nil
        
        // Act
        ButtonMerchant.configure(applicationId: "app-test")
        
        // Assert
        XCTAssertTrue(ButtonMerchant._instance is ButtonMerchant.Internal)
    }

    func testTrackIncomingURL() {
        // Arrange
        let expectedUrl = URL(string: "usebutton.com")!
        ButtonMerchant._instance = testInstance
        
        // Act
        ButtonMerchant.trackIncomingURL(expectedUrl)
        let actualUrl = testInstance.testUrl

        // Assert
        XCTAssertEqual(actualUrl, expectedUrl)
    }
    
    func testTrackIncomingUserActivity() {
        // Arrange
        let expectedUrl = URL(string: "https://usebutton.com")!
        let userActivity = NSUserActivity(activityType: "com.usebutton.web_activity")
        userActivity.webpageURL = expectedUrl
        
        // Act
        ButtonMerchant._instance = testInstance
        ButtonMerchant.trackIncomingUserActivity(userActivity)
        let actualUrl = testInstance.testUrl
        
        // Assert
        XCTAssertEqual(actualUrl, expectedUrl)
    }

    func testAccessingAttributionToken() {
        // Arrange
        testInstance.testToken = "srctok-123"
        let expectedToken = testInstance.testToken

        // Act
        ButtonMerchant._instance = testInstance

        // Assert
        XCTAssertNotNil(ButtonMerchant.attributionToken)
        XCTAssertEqual(ButtonMerchant.attributionToken, expectedToken)
    }

    func testClearAllData() {
        // Arrange
        ButtonMerchant._instance = testInstance
        
        // Act
        ButtonMerchant.clearAllData()

        // Assert
        XCTAssertTrue(testInstance.didCallClearAllData)
    }

    func testHandlePostInstallURL() {
        // Arrange
        ButtonMerchant._instance = testInstance
        
        // Act
        ButtonMerchant.handlePostInstallURL { _, _  in }

        // Assert
        XCTAssertTrue(testInstance.didCallFetchPostInstallURL)
    }

    @available(*, deprecated)
    func testTrackOrder() {
        let expectation = self.expectation(description: "trackOrder deprecation error")
        
        // Arrange
        ButtonMerchant._instance = testInstance
        
        // Act
        ButtonMerchant.trackOrder(Order(id: "test", amount: Int64(12))) { error in
            
            // Assert
            XCTAssertEqual(error as? ButtonMerchantError, ButtonMerchantError.trackOrderDeprecationError)
            
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportOrder() {
        // Arrange
        let expectedOrder = Order(id: "test",
                                  purchaseDate: Date(),
                                  lineItems: [Order.LineItem(id: "unique-id-1234", total: 400)])
        ButtonMerchant._instance = testInstance
        
        // Act
        ButtonMerchant.reportOrder(expectedOrder) { _ in }
        
        // Assert
        XCTAssertEqual(testInstance.testOrder, expectedOrder)
    }
    
    func testIFASetFalse() {
        // Arrange
        ButtonMerchant._instance = testInstance
        
        // Act
        ButtonMerchant.features.includesIFA = false
        
        // Assert
        XCTAssertFalse(ButtonMerchant.features.includesIFA)
    }
    
    func testIFASetTrue() {
        // Arrange
        ButtonMerchant._instance = testInstance
        
        // Act
        ButtonMerchant.features.includesIFA = true
        
        // Assert
        XCTAssertTrue(ButtonMerchant.features.includesIFA)
    }
    
    func testActivity_returnsClient() {
        ButtonMerchant._instance = testInstance
        XCTAssertEqualReferences(ButtonMerchant.activity, testInstance.client)
    }
    
    func testActivity_productViewed_invokesClient() {
        // Arrange
        ButtonMerchant._instance = testInstance
        let product = ButtonProduct()
        product.name = "some name"
        
        // Act
        ButtonMerchant.activity.productViewed(product)
        
        // Assert
        let client = (testInstance.client as? TestClient)!
        XCTAssertTrue(client.didCallProductViewed)
        XCTAssertEqual(client.actualProduct?.name, "some name")
    }
    
    func testActivity_productAddedToCart_invokesClient() {
        // Arrange
        ButtonMerchant._instance = testInstance
        let product = ButtonProduct()
        product.name = "some name"
        
        // Act
        ButtonMerchant.activity.productAddedToCart(product)
        
        // Assert
        let client = (testInstance.client as? TestClient)!
        XCTAssertTrue(client.didCallProductAddedToCart)
        XCTAssertEqual(client.actualProduct?.name, "some name")
    }
    
    func testActivity_cartViewed_invokesClient() {
        // Arrange
        ButtonMerchant._instance = testInstance
        let product = ButtonProduct()
        product.name = "some name"
        
        // Act
        ButtonMerchant.activity.cartViewed([product])
        
        // Assert
        let client = (testInstance.client as? TestClient)!
        XCTAssertTrue(client.didCallCartViewed)
        XCTAssertEqual(client.actualProducts?.first?.name, "some name")
    }
}
