//
// CoreTests.swift
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

class CoreTests: XCTestCase {
    
    func testInitialization() {
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testSystem = TestSystem()
        let testClient = TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: testSystem))
        let testNotificationCenter = TestNotificationCenter()
        let core = Core(buttonDefaults: testDefaults,
                        client: testClient,
                        system: testSystem,
                        notificationCenter: testNotificationCenter)
        XCTAssertEqualReferences(core.buttonDefaults, testDefaults)
        XCTAssertEqualReferences(core.client, testClient)
        XCTAssertEqualReferences(core.system, testSystem)
        XCTAssertEqualReferences(core.notificationCenter, testNotificationCenter)
    }
    
    func testTrackIncomingURLIgnoresUnattributedURLs() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testNotificationCenter = TestNotificationCenter()
        let url = URL(string: "http://usebutton.com")!
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: TestSystem())),
                        system: TestSystem(),
                        notificationCenter: testNotificationCenter)

        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertFalse(testDefaults.didStoreToken)
        XCTAssertFalse(testNotificationCenter.didCallPostNotification)
        XCTAssertNil(testNotificationCenter.testNotificationName)
        XCTAssertNil(testNotificationCenter.testObject)
        XCTAssertNil(testNotificationCenter.testUserInfo)
    }
    
    func testTrackIncomingURLIgnoresURLsWithoutQueryItems() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testNotificationCenter = TestNotificationCenter()
        let url = URL(string: "http://usebutton.com/products/listing")!
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: TestSystem())),
                        system: TestSystem(),
                        notificationCenter: testNotificationCenter)

        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertFalse(testDefaults.didStoreToken)
        XCTAssertFalse(testNotificationCenter.didCallPostNotification)
        XCTAssertNil(testNotificationCenter.testNotificationName)
        XCTAssertNil(testNotificationCenter.testObject)
        XCTAssertNil(testNotificationCenter.testUserInfo)
    }
    
    func testTrackIncomingURLPersistsAttributionToken() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let expectedSourceToken = "srctok-123"
        let url = URL(string: "http://usebutton.com/test?btn_ref=\(expectedSourceToken)")!
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: TestSystem())),
                        system: TestSystem(),
                        notificationCenter: TestNotificationCenter())

        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertEqual(expectedSourceToken, testDefaults.testToken)
    }
    
    func testTrackIncomingURLPostsNotification() {
        // Arrange
        let testNotificationCenter = TestNotificationCenter()
        let expectedSourceToken = "srctok-123"
        let url = URL(string: "http://usebutton.com/test?btn_ref=\(expectedSourceToken)")!
        let core = Core(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                        client: TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: TestSystem())),
                        system: TestSystem(),
                        notificationCenter: testNotificationCenter)
        
        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertTrue(testNotificationCenter.didCallPostNotification)
        XCTAssertNil(testNotificationCenter.testObject)
        XCTAssertEqual(testNotificationCenter.testNotificationName,
                       Notification.Name.Button.AttributionTokenDidChange)
        XCTAssertEqual(testNotificationCenter.testUserInfo! as NSDictionary,
                       [Notification.Key.NewToken: expectedSourceToken])
    }
    
    func testTrackIncomingURLAgainPostsNotification() {
        // Arrange
        let testNotificationCenter = TestNotificationCenter()
        let firstURL = URL(string: "http://usebutton.com/test?btn_ref=srctok-123")!
        let expectedSourceToken = "srctok-321"
        let secondURL = URL(string: "http://usebutton.com/test?btn_ref=\(expectedSourceToken)")!
        let core = Core(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                        client: TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: TestSystem())),
                        system: TestSystem(),
                        notificationCenter: testNotificationCenter)
        
        // Act
        core.trackIncomingURL(firstURL)
        core.trackIncomingURL(secondURL)
        
        // Assert
        XCTAssertTrue(testNotificationCenter.didCallPostNotification)
        XCTAssertNil(testNotificationCenter.testObject)
        XCTAssertEqual(testNotificationCenter.testNotificationName,
                       Notification.Name.Button.AttributionTokenDidChange)
        XCTAssertEqual(testNotificationCenter.testUserInfo! as NSDictionary,
                       [Notification.Key.NewToken: expectedSourceToken])
    }
    
    func testAttributionTokenReturnsStoredToken() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let expectedToken = "srctok-123"
        testDefaults.testToken = expectedToken
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: TestSystem())),
                        system: TestSystem(),
                        notificationCenter: TestNotificationCenter())

        // Act
        let actualToken = core.attributionToken
        
        // Assert
        XCTAssertEqual(actualToken, expectedToken)
    }

    func testClearAllDataInvokesButtonDefaults() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: TestSystem())),
                        system: TestSystem(),
                        notificationCenter: TestNotificationCenter())

        // Act
        core.clearAllData()
        
        // Assert
        XCTAssertTrue(testDefaults.didCallClearAllData)
    }

    func testHandlePostInstallURL() {
        // Arrange
        let expectation = XCTestExpectation(description: "handle post install url")
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testSystem = TestSystem()
        let testClient = TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: testSystem))
        let core = Core(buttonDefaults: testDefaults,
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = true
        core.applicationId = "app-123"

        // Act
        let expectedURL = URL(string: "http://test.com")
        let expectedToken = "srctok-123"
        core.handlePostInstallURL { url, _ in

            // Assert
            XCTAssertEqual(url, expectedURL)
            XCTAssertTrue(testDefaults.didStoreToken)
            XCTAssertNotNil(testDefaults.attributionToken)
            XCTAssertEqual(testDefaults.attributionToken, expectedToken)
            expectation.fulfill()
        }
        XCTAssertEqual(testClient.testParameters as NSDictionary,
                       ["application_id": "app-123",
                        "ifa": "00000000-0000-0000-0000-000000000000",
                        "ifa_limited": false,
                        "signals":
                            ["source": "button-merchant",
                             "os": "ios",
                             "os_version": "11.0",
                             "device": "iPhone",
                             "country": "US",
                             "language": "en",
                             "screen": "1080x1920"]])
        testClient.postInstallCompletion!(expectedURL, expectedToken)

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testHandlePostInstallURLNoAppIdError() {

        // Arrange
        let expectation = XCTestExpectation(description: "handle post install error")
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testSystem = TestSystem()
        let testClient = TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: testSystem))
        let core = Core(buttonDefaults: testDefaults,
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = true
        core.applicationId = ""

        // Act
        core.handlePostInstallURL { _, error in

            // Assert
            XCTAssertEqual(error as? ConfigurationError, ConfigurationError.noApplicationId)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testShouldFetchPostInstallURL_neverFetched_newInstall() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testSystem = TestSystem()
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: TestSystem())),
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = true

        // Act
        core.handlePostInstallURL { _, _ in }

        // Assert
        XCTAssertTrue(core.shouldFetchPostInstallURL)
    }

    func testShouldFetchPostInstallURL_neverFetched_oldInstall() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testSystem = TestSystem()
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: TestSystem())),
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = false

        // Act
        core.handlePostInstallURL { _, _ in }

        // Assert
        XCTAssertFalse(core.shouldFetchPostInstallURL)
    }

    @available(*, deprecated)
    func testTrackOrder() {
        // Arrange
        let expectation = XCTestExpectation(description: "track order")
        let order = Order(id: "order-abc", amount: 120)
        let testSystem = TestSystem()
        let testClient = TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: testSystem))
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        testDefaults.testToken = "srctok-abc123"
        let core = Core(buttonDefaults: testDefaults,
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        core.applicationId = "app-abc123"
        
        // Act
        core.trackOrder(order) { error in
            
            // Assert
            XCTAssertNil(error)
            expectation.fulfill()
        }
        XCTAssertEqual(testClient.testParameters as NSDictionary,
                       ["app_id": "app-abc123",
                        "user_local_time": "2018-01-23T12:00:00Z",
                        "btn_ref": "srctok-abc123",
                        "order_id": "order-abc",
                        "total": 120,
                        "currency": "USD",
                        "source": "merchant-library"])
        testClient.trackOrderCompletion!(nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }

    @available(*, deprecated)
    func testTrackOrderWithoutAttributionToken() {
        // Arrange
        let expectation = XCTestExpectation(description: "track order")
        let order = Order(id: "order-abc", amount: 120)
        let testSystem = TestSystem()
        let testClient = TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: testSystem))
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        testDefaults.testToken = nil
        let core = Core(buttonDefaults: testDefaults,
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        core.applicationId = "app-abc123"

        // Act
        core.trackOrder(order) { error in

            // Assert
            XCTAssertNil(error)
            expectation.fulfill()
        }
        XCTAssertEqual(testClient.testParameters as NSDictionary,
                       ["app_id": "app-abc123",
                        "user_local_time": "2018-01-23T12:00:00Z",
                        "order_id": "order-abc",
                        "total": 120,
                        "currency": "USD",
                        "source": "merchant-library"])
        testClient.trackOrderCompletion!(nil)

        self.wait(for: [expectation], timeout: 2.0)
    }

    @available(*, deprecated)
    func testTrackOrderError() {
        // Arrange
        let expectation = XCTestExpectation(description: "track order error")
        let order = Order(id: "test", amount: 120)
        let testSystem = TestSystem()
        let testClient = TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: testSystem))
        let core = Core(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        core.applicationId = ""

        // Act
        core.trackOrder(order) { error in

            // Assert
            XCTAssertEqual(error as? ConfigurationError, ConfigurationError.noApplicationId)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportOrder() {
        // Arrange
        let expectation = XCTestExpectation(description: "track order")
        Date.ISO8601Formatter.timeZone = TimeZone(identifier: "UTC")
        let date: Date = Date.ISO8601Formatter.date(from: "2019-06-17T12:08:10-04:00")!
        let email = "test@button.com"
        let lineItems = [Order.LineItem(identifier: "unique-id-1234", total: 120)]
        let customer = Order.Customer(id: "customer-id-123")
        customer.email = email
        let order = Order(id: "order-abc", purchaseDate: date, lineItems: lineItems)
        order.customer = customer
        order.customerOrderId = "customer-order-id-123"
        let testSystem = TestSystem()
        let testClient = TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: testSystem))
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        testDefaults.testToken = "srctok-abc123"
        let core = Core(buttonDefaults: testDefaults,
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        core.applicationId = "app-abc123"
        
        // Act
        core.reportOrder(order) { error in
            
            // Assert
            XCTAssertNil(error)
            expectation.fulfill()
        }

        XCTAssertEqual(testClient.testParameters as NSDictionary,
                       ["app_id": "app-abc123",
                        "user_local_time": "2018-01-23T12:00:00Z",
                        "btn_ref": "srctok-abc123",
                        "order_id": "order-abc",
                        "currency": "USD",
                        "purchase_date": date.ISO8601String,
                        "customer_order_id": "customer-order-id-123",
                        "line_items": [["identifier": "unique-id-1234", "quantity": 1, "total": 120]],
                        "customer": ["id": "customer-id-123", "email": email],
                        "source": "merchant-library"])
        testClient.reportOrderCompletion!(nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportOrderWithoutAttributionToken() {
        // Arrange
        let expectation = XCTestExpectation(description: "track order")
        Date.ISO8601Formatter.timeZone = TimeZone(identifier: "UTC")
        let date: Date = Date.ISO8601Formatter.date(from: "2019-06-17T12:08:10-04:00")!
        let email = "test@button.com"
        let customer = Order.Customer(id: "customer-id-123")
        customer.email = email
        let lineItems = [Order.LineItem(identifier: "unique-id-1234", total: 120)]
        let order = Order(id: "order-abc", purchaseDate: date, lineItems: lineItems)
        order.customer = customer
        order.customerOrderId = "customer-order-id-123"
        let testSystem = TestSystem()
        let testClient = TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: testSystem))
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        testDefaults.testToken = nil
        let core = Core(buttonDefaults: testDefaults,
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        core.applicationId = "app-abc123"
        
        // Act
        core.reportOrder(order) { error in
            
            // Assert
            XCTAssertNil(error)
            expectation.fulfill()
        }

        XCTAssertEqual(testClient.testParameters as NSDictionary,
                       ["app_id": "app-abc123",
                        "user_local_time": "2018-01-23T12:00:00Z",
                        "order_id": "order-abc",
                        "currency": "USD",
                        "purchase_date": date.ISO8601String,
                        "customer_order_id": "customer-order-id-123",
                        "line_items": [["identifier": "unique-id-1234", "quantity": 1, "total": 120]],
                        "customer": ["id": "customer-id-123", "email": email],
                        "source": "merchant-library"])
        testClient.reportOrderCompletion!(nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportOrderError() {
        // Arrange
        let expectation = XCTestExpectation(description: "tracker order error")
        let order = Order(id: "order-abc", purchaseDate: Date(), lineItems: [])
        let testSystem = TestSystem()
        let testClient = TestClient(session: TestURLSession(), userAgent: TestUserAgent(system: testSystem))
        let core = Core(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        core.applicationId = ""
        
        // Act
        core.reportOrder(order) { error in
            
            // Assert
            XCTAssertEqual(error as? ConfigurationError, ConfigurationError.noApplicationId)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 2.0)
    }
}
