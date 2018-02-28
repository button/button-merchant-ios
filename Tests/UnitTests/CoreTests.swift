/**

 CoreTests.swift

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

class CoreTests: XCTestCase {
    
    func testInitializationInjectsDependencies() {
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testClient = TestClient(session: TestURLSession())
        let testSystem = TestSystem()
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
                        client: TestClient(session: TestURLSession()),
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
                        client: TestClient(session: TestURLSession()),
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
    
    func testTrackIncomingURLPassesBtnRefToUserDefaults() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let expectedSourceToken = "srctok-123"
        let url = URL(string: "http://usebutton.com/derp?btn_ref=\(expectedSourceToken)")!
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession()),
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
        let url = URL(string: "http://usebutton.com/derp?btn_ref=\(expectedSourceToken)")!
        let core = Core(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                        client: TestClient(session: TestURLSession()),
                        system: TestSystem(),
                        notificationCenter: testNotificationCenter)
        
        // Act
        core.trackIncomingURL(url)
        
        // Assert
        XCTAssertTrue(testNotificationCenter.didCallPostNotification)
        XCTAssertNotNil(testNotificationCenter.testNotificationName)
        XCTAssertNotNil(testNotificationCenter.testObject)
        XCTAssertNotNil(testNotificationCenter.testUserInfo)
        XCTAssertEqual(Notification.Name.Button.AttributionTokenDidChange, testNotificationCenter.testNotificationName)
        XCTAssertEqualReferences(core, testNotificationCenter.testObject! as AnyObject)
        let expectedUserInfo = [Notification.Key.NewToken: expectedSourceToken] as NSDictionary
        XCTAssertEqual(expectedUserInfo, testNotificationCenter.testUserInfo! as NSDictionary)
    }
    
    func testTrackIncomingURLAgainPostsNotification() {
        // Arrange
        let testNotificationCenter = TestNotificationCenter()
        let firstURL = URL(string: "http://usebutton.com/derp?btn_ref=srctok-123")!
        let expectedSourceToken = "srctok-321"
        let secondURL = URL(string: "http://usebutton.com/derp?btn_ref=\(expectedSourceToken)")!
        let core = Core(buttonDefaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                        client: TestClient(session: TestURLSession()),
                        system: TestSystem(),
                        notificationCenter: testNotificationCenter)
        
        // Act
        core.trackIncomingURL(firstURL)
        core.trackIncomingURL(secondURL)
        
        // Assert
        XCTAssertTrue(testNotificationCenter.didCallPostNotification)
        XCTAssertNotNil(testNotificationCenter.testNotificationName)
        XCTAssertNotNil(testNotificationCenter.testObject)
        XCTAssertNotNil(testNotificationCenter.testUserInfo)
        XCTAssertEqual(Notification.Name.Button.AttributionTokenDidChange, testNotificationCenter.testNotificationName)
        XCTAssertEqualReferences(core, testNotificationCenter.testObject! as AnyObject)
        let expectedUserInfo = [Notification.Key.NewToken: expectedSourceToken] as NSDictionary
        XCTAssertEqual(expectedUserInfo, testNotificationCenter.testUserInfo! as NSDictionary)
    }
    
    func testAccessingAttributionToken() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let expectedToken = "srctok-123"
        testDefaults.testToken = expectedToken
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession()),
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
                        client: TestClient(session: TestURLSession()),
                        system: TestSystem(),
                        notificationCenter: TestNotificationCenter())

        // Act
        core.clearAllData()
        
        // Assert
        XCTAssertTrue(testDefaults.didCallClearAllData)
    }
    
    func testHandlePostInstallURLInvokesClientWhenAppIdIsSet() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testClient = TestClient(session: TestURLSession())
        let testSystem = TestSystem()
        let core = Core(buttonDefaults: testDefaults,
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        core.applicationId = "app-123"
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = true

        // Act
        core.handlePostInstallURL { _, _ in }
        
        // Assert
        XCTAssertTrue(testClient.didCallGetPostInstallLink)
    }
    
    func testHandlePostInstallURLIgnoresClientWhenAppIdIsNotSet() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testClient = TestClient(session: TestURLSession())
        let testSystem = TestSystem()
        let core = Core(buttonDefaults: testDefaults,
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = true

        // Act
        core.handlePostInstallURL { _, _ in }
        
        // Assert
        XCTAssertFalse(testClient.didCallGetPostInstallLink)
    }

    func testHandlePostInstallURLParameters() {

        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testClient = TestClient(session: TestURLSession())
        let testSystem = TestSystem()
        let core = Core(buttonDefaults: testDefaults,
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = true
        core.applicationId = "app-123"

        // Act
        core.handlePostInstallURL { _, _ in }
        let actualParameters = testClient.testParameters

        //Assert
        let expectedParameters = ["application_id": "app-123",
                                  "ifa": "00000000-0000-0000-0000-000000000000",
                                  "ifa_limited": false,
                                  "signals":
                                    ["source": "button-merchant",
                                     "os": "ios",
                                     "os_version": "11.0",
                                     "device": "iPhone",
                                     "country": "US",
                                     "language": "en",
                                     "screen": "1080x1920"]] as NSDictionary
        XCTAssertEqual(expectedParameters, actualParameters as NSDictionary)
    }

    func testHandlePostInstallURLCompletionURL() {
        // Arrange
        let expectation = XCTestExpectation(description: "handle post install url")
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testClient = TestClient(session: TestURLSession())
        let testSystem = TestSystem()
        let core = Core(buttonDefaults: testDefaults,
                        client: testClient,
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = true
        core.applicationId = "app-123"

        // Act
        let expectedURL = URL(string: "http://test.com")
        core.handlePostInstallURL { url, _ in

            // Assert
            XCTAssertEqual(url, expectedURL)
            expectation.fulfill()
        }
        testClient.postInstallCompletion!(expectedURL, nil)
        self.wait(for: [expectation], timeout: 2.0)
    }

    func testHandlePostInstallURLCompletionNoAppIdError() {
        // Arrange
        let expectation = XCTestExpectation(description: "handle post install error")
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testClient = TestClient(session: TestURLSession())
        let testSystem = TestSystem()
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
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 2.0)
    }

    func testShouldFetchPostInstallURL_neverFetched_newInstall() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testSystem = TestSystem()
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession()),
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
                        client: TestClient(session: TestURLSession()),
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        testDefaults.testHasFetchedPostInstallURL = false
        testSystem.testIsNewInstall = false

        // Act
        core.handlePostInstallURL { _, _ in }

        // Assert
        XCTAssertFalse(core.shouldFetchPostInstallURL)
    }

    func testShouldFetchPostInstallURL_hasFetched_newInstall() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testSystem = TestSystem()
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession()),
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        testDefaults.testHasFetchedPostInstallURL = true
        testSystem.testIsNewInstall = true

        // Act
        core.handlePostInstallURL { _, _ in }

        // Assert
        XCTAssertFalse(core.shouldFetchPostInstallURL)
    }

    func testShouldFetchPostInstallURL_hasFetched_oldInstall() {
        // Arrange
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let testSystem = TestSystem()
        let core = Core(buttonDefaults: testDefaults,
                        client: TestClient(session: TestURLSession()),
                        system: testSystem,
                        notificationCenter: TestNotificationCenter())
        testDefaults.testHasFetchedPostInstallURL = true
        testSystem.testIsNewInstall = false

        // Act
        core.handlePostInstallURL { _, _ in }

        // Assert
        XCTAssertFalse(core.shouldFetchPostInstallURL)
    }

}
