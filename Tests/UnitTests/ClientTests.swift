//
// ClientTests.swift
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

// swiftlint:disable file_length type_body_length
class ServiceTests: XCTestCase {
    
    let appId = ApplicationId("app-test")
    
    func testService_postInstallCase_urlWith_returnsPostInstallURL() {
        XCTAssertEqual(Service.postInstall.urlWith(appId).absoluteString, "https://app-test.mobileapi.usebutton.com/v1/app/deferred-deeplink")
    }
    
    func testService_orderCase_urlWith_returnsOrderURL() {
        XCTAssertEqual(Service.order.urlWith(appId).absoluteString, "https://app-test.mobileapi.usebutton.com/v1/app/order")
    }
    
    func testService_appEventsCase_urlWith_returnsAppEventsURL() {
        XCTAssertEqual(Service.appEvents.urlWith(appId).absoluteString, "https://app-test.mobileapi.usebutton.com/v1/app/events")
    }
    
    // Note: We fall back to dropping the appId though it's blocked at the external call sites.
    func testService_urlWithInvalidAppId_returnsURLWithoutAppId() {
        XCTAssertEqual(Service.appEvents.urlWith(ApplicationId("")).absoluteString, "https://mobileapi.usebutton.com/v1/app/events")
    }
}

class ClientTests: XCTestCase {

    func testInitialization() {
        // Arrange
        let expectedURLSession = TestURLSession()
        let expectedUserAgent = TestUserAgent()
        let defaults = TestButtonDefaults(userDefaults: TestUserDefaults())

        // Act
        let client = Client(session: expectedURLSession,
                            userAgent: expectedUserAgent,
                            defaults: defaults,
                            system: TestSystem())

        // Assert
        XCTAssertEqualReferences(client.session as AnyObject, expectedURLSession)
        XCTAssertEqualReferences(client.userAgent as AnyObject, expectedUserAgent)
        XCTAssertEqualReferences(client.defaults as AnyObject, defaults)
        XCTAssertNil(client.applicationId)
        XCTAssertFalse(client.isConfigured)
    }
    
    func testURLRequestCreatedWithParameters() {
        // Arrange
        let testUserAgent = TestUserAgent()
        let expectedURL = URL(string: "https://usebutton.com")!
        let inputParameters = ["test": "test", "some": "value"]
        let client = Client(session: TestURLSession(),
                            userAgent: testUserAgent,
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        client.applicationId = ApplicationId("app-abc123")
        
        // Act
        let request = client.urlRequest(url: expectedURL, parameters: inputParameters)
        let requestParameters = try? JSONSerialization.jsonObject(with: request.httpBody!)
        let parameters = requestParameters as? [String: String]
        
        // Assert
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), testUserAgent.stringRepresentation)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(parameters)
        XCTAssertEqual(parameters!, ["test": "test",
                                     "some": "value",
                                     "application_id": "app-abc123"])
    }
    
    func testURLRequest_whenSessionSet_addsSession() {
        // Arrange
        let testUserAgent = TestUserAgent()
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        testDefaults.sessionId = "some-session-id"
        let client = Client(session: TestURLSession(),
                            userAgent: testUserAgent,
                            defaults: testDefaults,
                            system: TestSystem())
        client.applicationId = ApplicationId("app-abc123")
        
        // Act
        let request = client.urlRequest(url: URL(string: "https://usebutton.com")!, parameters: ["foo": "bar"])
        let requestParameters = try? JSONSerialization.jsonObject(with: request.httpBody!)
        let parameters = requestParameters as? [String: String]

        // Assert
        XCTAssertEqual(parameters!, ["foo": "bar",
                                     "session_id": "some-session-id",
                                     "application_id": "app-abc123"])
    }

    func testURLRequestCreatedWithoutParameters() {
        // Arrange
        let testUserAgent = TestUserAgent()
        let expectedURL = URL(string: "https://usebutton.com")!
        let client = Client(session: TestURLSession(),
                            userAgent: testUserAgent,
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        client.applicationId = ApplicationId("app-abc123")
        
        // Act
        let request = client.urlRequest(url: expectedURL, parameters: nil)
        let requestParameters = try? JSONSerialization.jsonObject(with: request.httpBody!)
        let parameters = requestParameters as? [String: String]

        // Assert
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), testUserAgent.stringRepresentation)
        XCTAssertEqual(parameters!, ["application_id": "app-abc123"])
    }
    
    func testURLRequestCreated_noParams_noAppId_hasEmptyParams() {
        // Arrange
        let testUserAgent = TestUserAgent()
        let expectedURL = URL(string: "https://usebutton.com")!
        let client = Client(session: TestURLSession(),
                            userAgent: testUserAgent,
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        
        // Act
        let request = client.urlRequest(url: expectedURL, parameters: nil)
        let requestParameters = try? JSONSerialization.jsonObject(with: request.httpBody!)
        let parameters = requestParameters as? [String: String]

        // Assert
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), testUserAgent.stringRepresentation)
        XCTAssertEqual(parameters!, [:])
    }
    
    func testURLRequestNoParams_whenSessionSet_addsSession() {
        // Arrange
        let testUserAgent = TestUserAgent()
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        testDefaults.sessionId = "some-session-id"
        let client = Client(session: TestURLSession(),
                            userAgent: testUserAgent,
                            defaults: testDefaults,
                            system: TestSystem())
        client.applicationId = ApplicationId("app-abc123")

        // Act
        let request = client.urlRequest(url: URL(string: "https://usebutton.com")!, parameters: nil)
        let requestParameters = try? JSONSerialization.jsonObject(with: request.httpBody!)
        let parameters = requestParameters as? [String: String]

        // Assert
        XCTAssertEqual(parameters!, ["session_id": "some-session-id", "application_id": "app-abc123"])
    }
    
    func testEnqueueRequestCreatesDataTask() {
        // Arrange
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        client.applicationId = ApplicationId("app-test")
        
        // Act
        let request = URLRequest(url: URL(string: "https://usebutton.com")!)
        client.enqueueRequest(request: request) { _, _ in }
        
        // Assert
        XCTAssertTrue(testURLSession.didCallDataTaskWithRequest)
        XCTAssertNotNil(testURLSession.lastDataTask)
        XCTAssertEqual(testURLSession.lastDataTask?.originalRequest, request)
    }
    
    func testEnqueueRequestSuccess() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request success")
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        client.applicationId = ApplicationId("app-test")
        let expectedData = Data()
        
        // Act
        let url = URL(string: "https://usebutton.com")!
        client.enqueueRequest(request: URLRequest(url: url)) { data, error in
            
            // Assert
            XCTAssertNil(error)
            XCTAssertEqual(data, expectedData)
            
            expectation.fulfill()
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(expectedData, response, nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRequestSuccess_whenSessionId_persistsSessionId() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request success set session")
        let testURLSession = TestURLSession()
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: testDefaults,
                            system: TestSystem())
        client.applicationId = ApplicationId("app-test")
        let responseData = try? JSONSerialization.data(withJSONObject: [ "meta": ["session_id": "some-session-id"]])
        
        // Act
        let url = URL(string: "https://usebutton.com")!
        client.enqueueRequest(request: URLRequest(url: url)) { data, error in
            
            // Assert
            XCTAssertNil(error)
            XCTAssertEqual(testDefaults.sessionId, "some-session-id")
            
            expectation.fulfill()
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(responseData, response, nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRequestSuccess_whenNoSessionId_noChange() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request success set session")
        let testURLSession = TestURLSession()
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: testDefaults,
                            system: TestSystem())
        client.applicationId = ApplicationId("app-test")
        
        testDefaults.sessionId = "same-old-session"
        let responseData = try? JSONSerialization.data(withJSONObject: [ "meta": ["other": "fields"] ])
        
        // Act
        let url = URL(string: "https://usebutton.com")!
        client.enqueueRequest(request: URLRequest(url: url)) { data, error in
            
            // Assert
            XCTAssertNil(error)
            XCTAssertEqual(testDefaults.sessionId, "same-old-session")
            
            expectation.fulfill()
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(responseData, response, nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRequestSuccess_whenNewSessionId_persistsNewSessionId() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request success set session")
        let testURLSession = TestURLSession()
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: testDefaults,
                            system: TestSystem())
        client.applicationId = ApplicationId("app-test")
        
        testDefaults.sessionId = "some-old-session"
        let responseData = try? JSONSerialization.data(withJSONObject: [ "meta": ["session_id": "some-new-session"]])
        
        // Act
        let url = URL(string: "https://usebutton.com")!
        client.enqueueRequest(request: URLRequest(url: url)) { data, error in
            
            // Assert
            XCTAssertNil(error)
            XCTAssertEqual(testDefaults.sessionId, "some-new-session")
            
            expectation.fulfill()
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(responseData, response, nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRequestSuccess_whenSessionIdNull_clearsAllData() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request success set session")
        let testURLSession = TestURLSession()
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: testDefaults,
                            system: TestSystem())
        client.applicationId = ApplicationId("app-test")
        
        let responseData = try? JSONSerialization.data(withJSONObject: [ "meta": ["session_id": NSNull()]])
        
        // Act
        let url = URL(string: "https://usebutton.com")!
        client.enqueueRequest(request: URLRequest(url: url)) { data, error in
            
            // Assert
            XCTAssertNil(error)
            XCTAssertTrue(testDefaults.didCallClearAllData)
            
            expectation.fulfill()
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(responseData, response, nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRequestFailsNilData() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request fails nil data")
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        client.applicationId = ApplicationId("app-test")
        let expectedError = TestError.known
        
        // Act
        let url = URL(string: "https://usebutton.com")!
        client.enqueueRequest(request: URLRequest(url: url)) { data, error in
            
            // Assert
            XCTAssertNil(data)
            XCTAssertEqual(error as? TestError, expectedError)
            
            expectation.fulfill()
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(nil, response, expectedError)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRequestFailsBadResponseCode() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request fails bad response code")
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        client.applicationId = ApplicationId("app-test")
        let data = Data()
        let expectedError = TestError.known
        
        // Act
        let url = URL(string: "https://usebutton.com")!
        client.enqueueRequest(request: URLRequest(url: url)) { data, error in
            
            // Assert
            XCTAssertNil(data)
            XCTAssertEqual(error as? TestError, expectedError)
            
            expectation.fulfill()
        }
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(data, response, expectedError)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRequest_completion_isOnMainQueue() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request completes on main")
        let testURLSession = TestURLSession()
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: testDefaults,
                            system: TestSystem())
        client.applicationId = ApplicationId("app-test")
        let url = URL(string: "https://usebutton.com")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // Act
        client.enqueueRequest(request: URLRequest(url: url)) { data, error in
            
            // Assert
            XCTAssertTrue(Thread.isMainThread)
            
            expectation.fulfill()
        }
        DispatchQueue.global(qos: .background).async {
            testURLSession.lastDataTask?.completion(Data(), response, nil)
        }
        
        self.wait(for: [expectation], timeout: 2.0)
    }

    func testFetchPostInstallURLEnqueuesRequest() {
        // Arrange
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        client.applicationId = ApplicationId("app-abc123")
        let expectedURL = URL(string: "https://app-abc123.mobileapi.usebutton.com/v1/app/deferred-deeplink")!

        // Act
        client.fetchPostInstallURL { _, _ in }

        // Assert
        XCTAssertTrue(testURLSession.didCallDataTaskWithRequest)
        XCTAssertNotNil(testURLSession.lastDataTask)
        XCTAssertNotNil(testURLSession.lastDataTask?.originalRequest!.url)
        XCTAssertEqual(testURLSession.lastDataTask?.originalRequest!.url, expectedURL)
    }
    
    func testFetchPostInstallURLSuccess() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install url success")
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        client.applicationId = ApplicationId("app-test")
        let expectedURL = URL(string: "https://usebutton.com")!
        let expectedToken = "srctok-abc123"
        let responseDict: [String: Any] = ["object": ["action": expectedURL.absoluteString,
                                                      "attribution": ["btn_ref": expectedToken]]]
        let data = try? JSONSerialization.data(withJSONObject: responseDict)
        
        // Act
        client.fetchPostInstallURL { url, token in
            
            // Assert
            XCTAssertEqual(url, expectedURL)
            XCTAssertEqual(token, expectedToken)
            
            expectation.fulfill()
        }
        
        let response = HTTPURLResponse(url: expectedURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(data, response, nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchPostInstallURLFailsBadResponse() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install url fails bad response")
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        client.applicationId = ApplicationId("app-test")
        let url = URL(string: "https://usebutton.com")!
        let responseDict = ["blargh": "blergh"]
        let data = try? JSONSerialization.data(withJSONObject: responseDict)
        
        // Act
        client.fetchPostInstallURL { url, token in
            
            // Assert
            XCTAssertNil(url)
            XCTAssertNil(token)
            
            expectation.fulfill()
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(data, response, nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportOrder_reportsRequestWithSession() {
        // Arrange
        let expectation = XCTestExpectation(description: "report order")
        let session = TestURLSession()
        let client = Client(session: session,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        client.applicationId = ApplicationId("app-abc123")
        let request = TestReportOrderRequest(parameters: ["foo": "bar"])
        
        // Act
        client.reportOrder(orderRequest: request) { error in
            
            // Assert
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        XCTAssertEqualReferences(request.testSession as AnyObject, session)
        XCTAssertEqual(request.testRequest?.url, URL(string: "https://app-abc123.mobileapi.usebutton.com/v1/app/order")!)
        XCTAssertEqual(request.testRequest?.httpMethod, "POST")
        let body = try? JSONSerialization.jsonObject(with: (request.testRequest?.httpBody)!) as? [String: String]
        XCTAssertEqual(body, ["foo": "bar", "application_id": "app-abc123"])
        
        request.testCompletion!(Data(), nil)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportOrder_whenSessionId_persistsSessionId() {
        // Arrange
        let expectation = XCTestExpectation(description: "report order persists session id")
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let client = Client(session: TestURLSession(),
                            userAgent: TestUserAgent(),
                            defaults: testDefaults,
                            system: TestSystem())
        client.applicationId = ApplicationId("app-abc123")
        let request = TestReportOrderRequest(parameters: ["foo": "bar"])
        let responseData = try? JSONSerialization.data(withJSONObject: [ "meta": ["session_id": "some-session-id"]])
        
        // Act
        client.reportOrder(orderRequest: request) { error in
            
            // Assert
            XCTAssertNil(error)
            XCTAssertEqual(testDefaults.sessionId, "some-session-id")
            
            expectation.fulfill()
        }
        request.testCompletion!(responseData, nil)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportEvents_whenSuccess_hasNoErrors() {
        // Arrange
        let expectation = XCTestExpectation(description: "report events succeeds")
        let testSession = TestURLSession()
        let testSystem = TestSystem()
        testSystem.testCurrentDate = Date.eventDateFrom("2019-07-25T21:30:02.844Z")!
        let client = Client(session: testSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: testSystem)
        client.applicationId = ApplicationId("app-abc123")
        let event = AppEvent(name: "test-event", value: ["foo": "bar"], attributionToken: "some token", time: "some time", uuid: "some uuid")
        
        // Act
        client.reportEvents([event], ifa: "some ifa") { error in
            let request = testSession.lastDataTask?.originalRequest!
            let body = try? JSONDecoder().decode(AppEventsRequestBody.self, from: request!.httpBody!)
            
            // Assert
            XCTAssertNil(error)
            XCTAssertEqual(request?.url?.absoluteString, "https://app-abc123.mobileapi.usebutton.com/v1/app/events")
            XCTAssertEqual(body.dictionaryRepresentation as NSDictionary, [
                "ifa": "some ifa",
                "current_time": "2019-07-25T21:30:02.844Z",
                "events": [
                    [
                        "name": "test-event",
                        "value": ["foo": "bar"],
                        "promotion_source_token": "some token",
                        "time": "some time",
                        "uuid": "some uuid"
                    ]
                ]])
            
            expectation.fulfill()
        }
        
        let url = URL(string: "https://api.usebutton.com/v1/app/events")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testSession.lastDataTask?.completion(nil, response, nil)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportEvents_emptyEvents_doesNothing() {
        // Arrange
        let expectation = XCTestExpectation(description: "report empty events fails")
        let testSession = TestURLSession()
        let client = Client(session: testSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        client.applicationId = ApplicationId("app-abc123")
        
        // Act
        client.reportEvents([], ifa: "some ifa") { error in
            
            // Assert
            XCTAssertFalse(testSession.didCallDataTaskWithRequest)
            XCTAssertEqual(error as? ButtonMerchantError, ButtonMerchantError.noEventsError)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testAnyRequest_notConfigured_collectsAsPendingTasks() {
        // Arrange
        let client = Client(session: TestURLSession(),
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        let event = AppEvent(name: "event1", value: nil, attributionToken: "some token", time: "some time", uuid: "some uuid")
        
        // Act
        client.fetchPostInstallURL { _, _  in }
        client.reportEvents([event], ifa: "some ifa") { _ in }
        
        // Assert
        XCTAssertEqual(client.pendingTasks.count, 2)
        XCTAssertEqual(client.pendingTasks[0].urlRequest.url?.absoluteString, "https://mobileapi.usebutton.com/v1/app/deferred-deeplink")
        XCTAssertEqual(client.pendingTasks[1].urlRequest.url?.absoluteString, "https://mobileapi.usebutton.com/v1/app/events")
    }
    
    func testSetApplicationId_withAppId_flagsConfigured() {
        // Arrange
        let client = Client(session: TestURLSession(),
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        
        // Act
        client.applicationId = ApplicationId("app-test")
        
        // Assert
        XCTAssertTrue(client.isConfigured)
    }
    
    func testSetApplicationId_withNilAppId_flagsConfigured() {
        // Arrange
        let client = Client(session: TestURLSession(),
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        
        // Act
        client.applicationId = ApplicationId("bad id") // Note: we allow bad requests if configure has been called.
        
        // Assert
        XCTAssertTrue(client.isConfigured)
    }
    
    func testSetApplicationId_withPendingTasks_AttachedAppIdAndFlushesPendingTasks() {
        // Arrange
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: TestSystem())
        let event = AppEvent(name: "event1", value: nil, attributionToken: "some token", time: "some time", uuid: "some uuid")
        client.fetchPostInstallURL { _, _  in }
        client.reportEvents([event], ifa: "some ifa") { _ in }
        
        // Act
        client.applicationId = ApplicationId("app-test")
        
        // Assert
        XCTAssertEqual(testURLSession.allDataTasks.count, 2)
        XCTAssertEqual(testURLSession.allDataTasks[0].originalRequest?.url?.absoluteString,
                       "https://app-test.mobileapi.usebutton.com/v1/app/deferred-deeplink")
        XCTAssertEqual(testURLSession.allDataTasks[1].originalRequest?.url?.absoluteString,
                       "https://app-test.mobileapi.usebutton.com/v1/app/events")
        XCTAssertEqual(client.pendingTasks.count, 0)
        testURLSession.allDataTasks.forEach { task in
            let json = try? JSONSerialization.jsonObject(with: task.originalRequest!.httpBody!) as? NSDictionary
            XCTAssertEqual(json?["application_id"] as? String, "app-test")
        }
    }
    
    func testProductViewed_enqueuesRequest() {
        // Arrange
        let testURLSession = TestURLSession()
        let testSystem = TestSystem()
        testSystem.advertisingId = "some ifa"
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: testSystem)
        client.applicationId = ApplicationId("app-abc123")
        
        // Act
        client.productViewed(nil)
        
        // Assert
        XCTAssertEqual(testURLSession.allDataTasks.count, 1)
        let task = testURLSession.allDataTasks.first!
        XCTAssertEqual(task.originalRequest?.url?.absoluteString,
                       "https://app-abc123.mobileapi.usebutton.com/v1/app/activity")
        let json = try? JSONSerialization.jsonObject(with: task.originalRequest!.httpBody!) as? NSDictionary
        XCTAssertEqual(json?["ifa"] as? String, "some ifa")
        XCTAssertEqual((json?["activity_data"] as? NSDictionary)?["name"] as? String, "product-viewed")
    }
    
    func testProductAddedToCart_enqueuesRequest() {
        // Arrange
        let testURLSession = TestURLSession()
        let testSystem = TestSystem()
        testSystem.advertisingId = "some ifa"
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: testSystem)
        client.applicationId = ApplicationId("app-abc123")
        
        // Act
        client.productAddedToCart(nil)
        
        // Assert
        XCTAssertEqual(testURLSession.allDataTasks.count, 1)
        let task = testURLSession.allDataTasks.first!
        XCTAssertEqual(task.originalRequest?.url?.absoluteString,
                       "https://app-abc123.mobileapi.usebutton.com/v1/app/activity")
        let json = try? JSONSerialization.jsonObject(with: task.originalRequest!.httpBody!) as? NSDictionary
        XCTAssertEqual(json?["ifa"] as? String, "some ifa")
        XCTAssertEqual((json?["activity_data"] as? NSDictionary)?["name"] as? String, "add-to-cart")
    }
    
    func testCartViewed_enqueuesRequest() {
        // Arrange
        let testURLSession = TestURLSession()
        let testSystem = TestSystem()
        testSystem.advertisingId = "some ifa"
        let client = Client(session: testURLSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()),
                            system: testSystem)
        client.applicationId = ApplicationId("app-abc123")
        
        // Act
        client.cartViewed(nil)
        
        // Assert
        XCTAssertEqual(testURLSession.allDataTasks.count, 1)
        let task = testURLSession.allDataTasks.first!
        XCTAssertEqual(task.originalRequest?.url?.absoluteString,
                       "https://app-abc123.mobileapi.usebutton.com/v1/app/activity")
        let json = try? JSONSerialization.jsonObject(with: task.originalRequest!.httpBody!) as? NSDictionary
        XCTAssertEqual(json?["ifa"] as? String, "some ifa")
        XCTAssertEqual((json?["activity_data"] as? NSDictionary)?["name"] as? String, "cart-viewed")
    }
}
// swiftlint:enable file_length type_body_length
