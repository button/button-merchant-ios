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

class ClientTests: XCTestCase {

    func testInitialization() {
        // Arrange
        let expectedURLSession = TestURLSession()
        let expectedUserAgent = TestUserAgent()
        let defaults = TestButtonDefaults(userDefaults: TestUserDefaults())

        // Act
        let client = Client(session: expectedURLSession, userAgent: expectedUserAgent, defaults: defaults)

        // Assert
        XCTAssertEqualReferences(client.session as AnyObject, expectedURLSession)
        XCTAssertEqualReferences(client.userAgent as AnyObject, expectedUserAgent)
        XCTAssertEqualReferences(client.defaults as AnyObject, defaults)
    }
    
    func testURLRequestCreatedWithParameters() {
        // Arrange
        let testUserAgent = TestUserAgent()
        let expectedURL = URL(string: "https://usebutton.com")!
        let inputParameters = ["test": "test", "some": "value"]
        let client = Client(session: TestURLSession(), userAgent: testUserAgent, defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
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
        let client = Client(session: TestURLSession(), userAgent: testUserAgent, defaults: testDefaults)
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
        let client = Client(session: TestURLSession(), userAgent: testUserAgent, defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
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
        let client = Client(session: TestURLSession(), userAgent: testUserAgent, defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
        
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
        let client = Client(session: TestURLSession(), userAgent: testUserAgent, defaults: testDefaults)
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
        let client = Client(session: testURLSession, userAgent: TestUserAgent(), defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
        
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
        let client = Client(session: testURLSession, userAgent: TestUserAgent(), defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
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
    
    func testEnqueueRequestSuccess_whenSession_persistsSession() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request success set session")
        let testURLSession = TestURLSession()
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let client = Client(session: testURLSession, userAgent: TestUserAgent(), defaults: testDefaults)
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
    
    func testEnqueueRequestSuccess_whenNoSession_noChange() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request success set session")
        let testURLSession = TestURLSession()
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let client = Client(session: testURLSession, userAgent: TestUserAgent(), defaults: testDefaults)
        
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
    
    func testEnqueueRequestSuccess_whenNewSession_persistsNewSession() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request success set session")
        let testURLSession = TestURLSession()
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let client = Client(session: testURLSession, userAgent: TestUserAgent(), defaults: testDefaults)
        
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
    
    func testEnqueueRequestSuccess_whenSessionNull_clearsAllData() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request success set session")
        let testURLSession = TestURLSession()
        let testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let client = Client(session: testURLSession, userAgent: TestUserAgent(), defaults: testDefaults)
        
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
        let client = Client(session: testURLSession, userAgent: TestUserAgent(), defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
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
        let client = Client(session: testURLSession, userAgent: TestUserAgent(), defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
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

    func testFetchPostInstallURLEnqueuesRequest() {
        // Arrange
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession, userAgent: TestUserAgent(), defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
        let expectedParameters = ["blargh": "blergh"]
        let expectedURL = URL(string: "https://api.usebutton.com/v1/web/deferred-deeplink")!

        // Act
        client.fetchPostInstallURL(parameters: expectedParameters) { _, _ in }
        let request = (testURLSession.lastDataTask?.originalRequest)!
        let requestParameters = try? JSONSerialization.jsonObject(with: request.httpBody!)
        let parameters = requestParameters as? [String: String]

        // Assert
        XCTAssertTrue(testURLSession.didCallDataTaskWithRequest)
        XCTAssertNotNil(testURLSession.lastDataTask)
        XCTAssertNotNil(testURLSession.lastDataTask?.originalRequest!.url)
        XCTAssertEqual(testURLSession.lastDataTask?.originalRequest!.url, expectedURL)
        XCTAssertNotNil(parameters)
        XCTAssertEqual(parameters!, expectedParameters)
    }
    
    func testFetchPostInstallURLSuccess() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install url success")
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession, userAgent: TestUserAgent(), defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
        let expectedURL = URL(string: "https://usebutton.com")!
        let expectedToken = "srctok-abc123"
        let responseDict: [String: Any] = ["object": ["action": expectedURL.absoluteString,
                                                      "attribution": ["btn_ref": expectedToken]]]
        let data = try? JSONSerialization.data(withJSONObject: responseDict)
        
        // Act
        client.fetchPostInstallURL(parameters: [:]) { url, token in
            
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
        let client = Client(session: testURLSession, userAgent: TestUserAgent(), defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
        let url = URL(string: "https://usebutton.com")!
        let responseDict = ["blargh": "blergh"]
        let data = try? JSONSerialization.data(withJSONObject: responseDict)
        
        // Act
        client.fetchPostInstallURL(parameters: [:]) { url, token in
            
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
        let client = Client(session: session, userAgent: TestUserAgent(), defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
        let request = TestReportOrderRequest(parameters: ["foo": "bar"], encodedApplicationId: "abc123")
        
        // Act
        client.reportOrder(orderRequest: request) { error in
            
            // Assert
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        XCTAssertEqualReferences(request.testSession as AnyObject, session)
        XCTAssertEqual(request.testRequest?.url, URL(string: "https://api.usebutton.com/v1/app/order")!)
        XCTAssertEqual(request.testRequest?.httpMethod, "POST")
        let body = try? JSONSerialization.jsonObject(with: (request.testRequest?.httpBody)!) as? [String: String]
        XCTAssertEqual(body, ["foo": "bar"])
        
        request.testCompletion!(nil)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportEvents_whenSuccess_hasNoErrors() {
        // Arrange
        let expectation = XCTestExpectation(description: "report events succeeds")
        let testSession = TestURLSession()
        let client = Client(session: testSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
        let event = AppEvent(name: "test-event", value: ["foo": "bar"], attributionToken: "some token")
        
        // Act
        client.reportEvents([event], ifa: "some ifa") { error in
            let request = testSession.lastDataTask?.originalRequest!
            let body = try? JSONDecoder().decode(AppEventsRequestBody.self, from: request!.httpBody!)
            
            // Assert
            XCTAssertNil(error)
            XCTAssertEqual(request?.url?.absoluteString, "https://api.usebutton.com/v1/app/events")
            XCTAssertEqual(body.dictionaryRepresentation as NSDictionary, [
            "ifa": "some ifa",
            "events": [
                [
                    "name": "test-event",
                    "value": ["foo": "bar"],
                    "promotion_source_token": "some token"
                ]
            ]])

            expectation.fulfill()
        }
        
        let url = URL(string: "https://api.usebutton.com/v1/app/events")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testSession.lastDataTask?.completion(nil, response, nil)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportEvents_empty_events_doesNothing() {
        // Arrange
        let expectation = XCTestExpectation(description: "report empty events fails")
        let testSession = TestURLSession()
        let client = Client(session: testSession,
                            userAgent: TestUserAgent(),
                            defaults: TestButtonDefaults(userDefaults: TestUserDefaults()))
        
        // Act
        client.reportEvents([], ifa: "some ifa") { error in
            
            // Assert
            XCTAssertFalse(testSession.didCallDataTaskWithRequest)
            XCTAssertEqual(error as? String, "No events to report")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
