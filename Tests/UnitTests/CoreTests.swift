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
    
    var testSystem: TestSystem!
    var testDefaults: TestButtonDefaults!
    var testNotificationCenter: TestNotificationCenter!
    var testClient: TestClient!
    var testVerifier: TestAppIntegrationVerification!
    var core: Core!
    
    override func setUp() {
        testSystem = TestSystem()
        testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        testNotificationCenter = TestNotificationCenter()
        testVerifier = TestAppIntegrationVerification(application: TestApplication(),
                                                      defaults: testDefaults)
        testClient = TestClient(session: TestURLSession(),
                                userAgent: TestUserAgent(system: testSystem),
                                defaults: testDefaults,
                                system: testSystem)
        core = Core(buttonDefaults: testDefaults,
                    client: testClient,
                    system: testSystem,
                    notificationCenter: testNotificationCenter,
                    verifier: testVerifier)
    }
    
    func testInitialization() {
        XCTAssertEqualReferences(core.buttonDefaults, testDefaults)
        XCTAssertEqualReferences(core.client, testClient)
        XCTAssertEqualReferences(core.system, testSystem)
        XCTAssertEqualReferences(core.notificationCenter, testNotificationCenter)
        XCTAssertEqualReferences(core.appIntegrationVerifier, testVerifier)
    }
    
    func testSetApplicationId_setClientApplicationId() {
        // Act
        core.applicationId = ApplicationId("app-abc123")
        
        // Assert
        XCTAssertEqual(testClient.applicationId?.rawValue, "app-abc123")
    }
    
    func testTrackIncomingURLIgnoresUnattributedURLs() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testNotificationCenter = TestNotificationCenter()
        let url = URL(string: "http://usebutton.com")!

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
        let url = URL(string: "http://usebutton.com/products/listing")!

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
        let expectedSourceToken = "srctok-123"
        let url = URL(string: "http://usebutton.com/test?btn_ref=\(expectedSourceToken)")!

        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertEqual(expectedSourceToken, testDefaults.testToken)
    }
    
    func testTrackIncomingURL_withToken_tracksDeeplinkOpened() {
        // Arrange
        testSystem.advertisingId = "some ifa"
        testSystem.testCurrentDate = Date.eventDateFrom("2019-07-25T21:30:02.844Z")!
        let url = URL(string: "http://usebutton.com/with-token?btn_ref=faketok-abc123")!
        
        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertTrue(testClient.didCallReportEvents)
        XCTAssertEqual(testClient.actualIFA, "some ifa")
        XCTAssertEqual(testClient.actualEvents?.count, 1)
        XCTAssertEqual(testClient.actualEvents?.first?.name, "btn:deeplink-opened")
        XCTAssertEqual(testClient.actualEvents?.first?.value?["url"], url.absoluteString)
        XCTAssertEqual(testClient.actualEvents?.first?.time, "2019-07-25T21:30:02.844Z")
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}")
        XCTAssertTrue(predicate.evaluate(with: testClient.actualEvents?.first?.uuid))
    }
    
    func testTrackIncomingURL_withoutToken_tracksDeeplinkOpened() {
        // Arrange
        testSystem.testCurrentDate = Date.eventDateFrom("2019-07-25T21:30:02.844Z")!
        let url = URL(string: "http://usebutton.com/no-token")!

        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertTrue(testClient.didCallReportEvents)
        XCTAssertEqual(testClient.actualEvents?.count, 1)
        XCTAssertEqual(testClient.actualEvents?.first?.name, "btn:deeplink-opened")
        XCTAssertEqual(testClient.actualEvents?.first?.value?["url"], url.absoluteString)
        XCTAssertEqual(testClient.actualEvents?.first?.time, "2019-07-25T21:30:02.844Z")
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}")
        XCTAssertTrue(predicate.evaluate(with: testClient.actualEvents?.first?.uuid))
    }
    
    func testTrackIncomingURL_withBTNParams_tracksDeeplinkOpened() {
        // Arrange
        testSystem.testCurrentDate = Date.eventDateFrom("2019-07-25T21:30:02.844Z")!
        let url = URL(string: "http://usebutton.com/no-token/?btn_1=1&btn_2=2&btn_ref=faketok-123")!

        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertTrue(testClient.didCallReportEvents)
        XCTAssertEqual(testClient.actualEvents?.count, 1)
        XCTAssertEqual(testClient.actualEvents?.first?.name, "btn:deeplink-opened")
        XCTAssertEqual(testClient.actualEvents?.first?.value?["url"], url.absoluteString)
        XCTAssertEqual(testClient.actualEvents?.first?.time, "2019-07-25T21:30:02.844Z")
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}")
        XCTAssertTrue(predicate.evaluate(with: testClient.actualEvents?.first?.uuid))
    }
    
    func testTrackIncomingURL_withFromLandingFromTrackingParams_tracksDeeplinkOpened() {
        // Arrange
        testSystem.testCurrentDate = Date.eventDateFrom("2019-07-25T21:30:02.844Z")!
        let url = URL(string: "http://usebutton.com/no-token/?from_landing=true&from_tracking=false")!

        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertTrue(testClient.didCallReportEvents)
        XCTAssertEqual(testClient.actualEvents?.count, 1)
        XCTAssertEqual(testClient.actualEvents?.first?.name, "btn:deeplink-opened")
        XCTAssertEqual(testClient.actualEvents?.first?.value?["url"], url.absoluteString)
        XCTAssertEqual(testClient.actualEvents?.first?.time, "2019-07-25T21:30:02.844Z")
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}")
        XCTAssertTrue(predicate.evaluate(with: testClient.actualEvents?.first?.uuid))
    }
    
    func testTrackIncomingURL_withoutButtonParams_tracksNoParams() {
        // Arrange
        testSystem.testCurrentDate = Date.eventDateFrom("2019-07-25T21:30:02.844Z")!
        let url = URL(string: "http://usebutton.com/no-token/?not_ours=param&also_not=same&utm_campaign=nope")!

        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertTrue(testClient.didCallReportEvents)
        XCTAssertEqual(testClient.actualEvents?.count, 1)
        XCTAssertEqual(testClient.actualEvents?.first?.name, "btn:deeplink-opened")
        XCTAssertEqual(testClient.actualEvents?.first?.value?["url"], "http://usebutton.com/no-token/?")
        XCTAssertEqual(testClient.actualEvents?.first?.time, "2019-07-25T21:30:02.844Z")
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}")
        XCTAssertTrue(predicate.evaluate(with: testClient.actualEvents?.first?.uuid))
    }
    
    func testTrackIncomingURL_withMixedParams_tracksWithButtonParams() {
        // Arrange
        testSystem.testCurrentDate = Date.eventDateFrom("2019-07-25T21:30:02.844Z")!
        let url = URL(string: "http://usebutton.com/no-token/?theirs=param&from_landing=1&btn_test=0")!

        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertTrue(testClient.didCallReportEvents)
        XCTAssertEqual(testClient.actualEvents?.count, 1)
        XCTAssertEqual(testClient.actualEvents?.first?.name, "btn:deeplink-opened")
        XCTAssertEqual(testClient.actualEvents?.first?.value?["url"], "http://usebutton.com/no-token/?from_landing=1&btn_test=0")
        XCTAssertEqual(testClient.actualEvents?.first?.time, "2019-07-25T21:30:02.844Z")
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}")
        XCTAssertTrue(predicate.evaluate(with: testClient.actualEvents?.first?.uuid))
    }
    
    func testTrackIncomingURL_withMixedCase_tracksWithButtonParams() {
        // Arrange
        testSystem.testCurrentDate = Date.eventDateFrom("2019-07-25T21:30:02.844Z")!
        let url = URL(string: "http://usebutton.com/no-token/?theirs=param&From_landing=1&Btn_test=0")!

        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertTrue(testClient.didCallReportEvents)
        XCTAssertEqual(testClient.actualEvents?.count, 1)
        XCTAssertEqual(testClient.actualEvents?.first?.name, "btn:deeplink-opened")
        XCTAssertEqual(testClient.actualEvents?.first?.value?["url"], "http://usebutton.com/no-token/?From_landing=1&Btn_test=0")
        XCTAssertEqual(testClient.actualEvents?.first?.time, "2019-07-25T21:30:02.844Z")
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}")
        XCTAssertTrue(predicate.evaluate(with: testClient.actualEvents?.first?.uuid))
    }
    
    func testTrackIncomingURLPostsNotification() {
        // Arrange
        let expectedSourceToken = "srctok-123"
        let url = URL(string: "http://usebutton.com/test?btn_ref=\(expectedSourceToken)")!
        
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
        let firstURL = URL(string: "http://usebutton.com/test?btn_ref=srctok-123")!
        let expectedSourceToken = "srctok-321"
        let secondURL = URL(string: "http://usebutton.com/test?btn_ref=\(expectedSourceToken)")!
        
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
    
    func testTrackIncomingURL_forwardsAttributedURL_toIntegrationVerifier() {
        // Arrange
        let url = URL(string: "https://usebutton.com/test?btn_ref=srctok-123")!
        
        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertEqual(testVerifier.actualURL, url)
    }
    
    func testTrackIncomingURL_forwardsAnyURL_toIntegrationVerifier() {
        // Arrange
        let url = URL(string: "https://example.com")!
        
        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertEqual(testVerifier.actualURL, url)
    }
    
    func testAttributionTokenReturnsStoredToken() {
        // Arrange
        let expectedToken = "srctok-123"
        testDefaults.testToken = expectedToken

        // Act
        let actualToken = core.attributionToken
        
        // Assert
        XCTAssertEqual(actualToken, expectedToken)
    }

    func testClearAllDataInvokesButtonDefaults() {
        // Act
        core.clearAllData()
        
        // Assert
        XCTAssertTrue(testDefaults.didCallClearAllData)
    }
    
    func testClearAllDataRemovesPendingTasks() {
        // Arrange
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let task = PendingTask(urlRequest: request) { _, _ in }
        testClient.pendingTasks.append(task)

        // Act
        core.clearAllData()
        
        // Assert
        XCTAssertTrue(testClient.pendingTasks.isEmpty)
    }

    func testHandlePostInstallURL() {
        // Arrange
        let expectation = XCTestExpectation(description: "handle post install url")
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = true
        core.applicationId = ApplicationId("app-123")

        // Act
        let expectedURL = URL(string: "http://test.com")
        let expectedToken = "srctok-123"
        core.handlePostInstallURL { url, _ in

            // Assert
            XCTAssertEqual(url, expectedURL)
            XCTAssertTrue(self.testDefaults.didStoreToken)
            XCTAssertNotNil(self.testDefaults.attributionToken)
            XCTAssertEqual(self.testDefaults.attributionToken, expectedToken)
            XCTAssertEqual(self.core.attributionToken, expectedToken)
            XCTAssertTrue(self.testNotificationCenter.didCallPostNotification)
            XCTAssertNil(self.testNotificationCenter.testObject)
            XCTAssertEqual(self.testNotificationCenter.testNotificationName,
                           Notification.Name.Button.AttributionTokenDidChange)
            XCTAssertEqual(self.testNotificationCenter.testUserInfo! as NSDictionary,
                           [Notification.Key.NewToken: expectedToken])
            expectation.fulfill()
        }
        XCTAssertEqual(testClient.testParameters as NSDictionary,
                       [
                        "ifa": "00000000-0000-0000-0000-000000000000",
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
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = true
        core.applicationId = ApplicationId("")

        // Act
        core.handlePostInstallURL { _, error in

            // Assert
            XCTAssertEqual(error as? ConfigurationError, ConfigurationError.noApplicationId)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testHandlePostInstall_existingToken_callsBackNil() {

        // Arrange
        let expectation = XCTestExpectation(description: "handle post install error")
        testDefaults.attributionToken = "existing token"
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = true
        core.applicationId = ApplicationId("app-123")

        // Act
        core.handlePostInstallURL { url, error in

            // Assert
            XCTAssertNil(url)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        testClient.postInstallCompletion!(URL(string: "https://example.com")!, "faketok-abc123")
        
        self.wait(for: [expectation], timeout: 2.0)
    }

    func testShouldFetchPostInstallURL_neverFetched_newInstall() {
        // Arrange
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = true

        // Act
        core.handlePostInstallURL { _, _ in }

        // Assert
        XCTAssertTrue(core.shouldFetchPostInstallURL)
    }

    func testShouldFetchPostInstallURL_neverFetched_oldInstall() {
        // Arrange
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = false

        // Act
        core.handlePostInstallURL { _, _ in }

        // Assert
        XCTAssertFalse(core.shouldFetchPostInstallURL)
    }
    
    func testReportOrder_success() {
        // Arrange
        let expectation = XCTestExpectation(description: "report order")
        Date.ISO8601Formatter.timeZone = TimeZone(identifier: "UTC")
        let date: Date = Date.ISO8601Formatter.date(from: "2019-06-17T12:08:10-04:00")!
        let lineItems = [Order.LineItem(id: "unique-id-1234", total: 120)]
        let customer = Order.Customer(id: "customer-id-123")
        customer.email = "test@button.com"
        customer.isNew = true
        let order = Order(id: "order-abc", purchaseDate: date, lineItems: lineItems)
        order.customer = customer
        order.customerOrderId = "customer-order-id-123"
        testDefaults.testToken = "srctok-abc123"
        core.applicationId = ApplicationId("app-abc123")
        
        // Act
        core.reportOrder(order) { error in
            
            // Assert
            XCTAssertNil(error)
            expectation.fulfill()
        }

        XCTAssertEqual(testClient.testReportOrderRequest!.parameters as NSDictionary,
                       ["advertising_id": "00000000-0000-0000-0000-000000000000",
                        "btn_ref": "srctok-abc123",
                        "order_id": "order-abc",
                        "currency": "USD",
                        "purchase_date": date.ISO8601String,
                        "customer_order_id": "customer-order-id-123",
                        "line_items": [["identifier": "unique-id-1234", "quantity": 1, "total": 120]],
                        "customer": ["id": "customer-id-123", "email_sha256": "21f61e98ab4ae120e88ac6b5dd218ffb8cf3e481276b499a2e0adab80092899c", "is_new": 1]])
        
        testClient.reportOrderCompletion!(nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportOrder_error() {
        // Arrange
        let expectation = XCTestExpectation(description: "report order error")
        let order = Order(id: "order-abc", purchaseDate: Date(), lineItems: [])
        core.applicationId = ApplicationId("")
        
        // Act
        core.reportOrder(order) { error in
            
            // Assert
            XCTAssertEqual(error as? ConfigurationError, ConfigurationError.noApplicationId)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 2.0)
    }
}
