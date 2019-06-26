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

        // Act
        let client = Client(session: expectedURLSession, userAgent: expectedUserAgent)

        // Assert
        XCTAssertEqualReferences(client.session as AnyObject, expectedURLSession)
        XCTAssertEqualReferences(client.userAgent as AnyObject, expectedUserAgent)
    }

    func testURLRequestCreatedWithParameters() {
        // Arrange
        let testUserAgent = TestUserAgent()
        let expectedURL = URL(string: "https://usebutton.com")!
        let expectedParameters = ["test": "test",
                                  "some": "value"]
        let client = Client(session: TestURLSession(), userAgent: testUserAgent)

        // Act
        let request = client.urlRequest(url: expectedURL, parameters: expectedParameters)
        let requestParameters = try? JSONSerialization.jsonObject(with: request.httpBody!)
        let parameters = requestParameters as? [String: String]

        // Assert
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), testUserAgent.stringRepresentation)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(parameters)
        XCTAssertEqual(parameters!, expectedParameters)
    }

    func testURLRequestCreatedWithoutParameters() {
        // Arrange
        let testUserAgent = TestUserAgent()
        let expectedURL = URL(string: "https://usebutton.com")!
        let client = Client(session: TestURLSession(), userAgent: testUserAgent)

        // Act
        let request = client.urlRequest(url: expectedURL, parameters: nil)

        // Assert
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), testUserAgent.stringRepresentation)
        XCTAssertNil(request.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertNil(request.httpBody)
    }
    
    func testEnqueueRequestCreatesDataTask() {
        // Arrange
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
        
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
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
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
    
    func testEnqueueRequestFailsNilData() {
        // Arrange
        let expectation = XCTestExpectation(description: "enqueue request fails nil data")
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
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
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
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
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
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
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
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
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
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

    func testTrackOrderEnqueuesRequest() {
        // Arrange
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
        let expectedParameters = ["blargh": "blergh"]
        let expectedURL = URL(string: "https://api.usebutton.com/v1/activity/order")!
        
        // Act
        client.trackOrder(parameters: expectedParameters) { _ in }
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
    
    func testTrackOrderSuccess() {
        // Arrange
        let expectation = XCTestExpectation(description: "track order success")
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
        let url = URL(string: "https://api.usebutton.com/v1/activity/order")!
        
        // Act
        client.trackOrder(parameters: [:]) { error in
            
            // Assert
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(Data(), response, nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testTrackOrderFails() {
        // Arrange
        let expectation = XCTestExpectation(description: "track order fails")
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
        let url = URL(string: "https://api.usebutton.com/v1/activity/order")!
        let expectedError = TestError.known
        
        // Act
        client.trackOrder(parameters: [:]) { error in
            
            // Assert
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? TestError, expectedError)
            
            expectation.fulfill()
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(nil, response, expectedError)

        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportOrderEnqueuesRequests() {
        // Arrange
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
        let expectedParameters = ["blargh": "blergh"]
        let expectedURL = URL(string: "https://api.usebutton.com/v1/mobile-order")!

        // Act
        client.reportOrder(parameters: expectedParameters, encodedApplicationId: "") { _ in }
        let request = (testURLSession.lastDataTask?.originalRequest)!
        let requestParameters = try? JSONSerialization.jsonObject(with: request.httpBody!)
        let parameters = requestParameters as? [String: String]

        // Assert
        XCTAssertTrue(testURLSession.didCallDataTaskWithRequest)
        XCTAssertEqual(testURLSession.lastDataTask?.originalRequest!.url, expectedURL)
        XCTAssertEqual(parameters!, expectedParameters)
    }

    func testReportOrder_addsAuthorizationHeader() {
        // Arrange
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
        let expectedAuthHeader = "Basic encoded_app_id:"

        // Act
        client.reportOrder(parameters: ["blargh": "blergh"], encodedApplicationId: "encoded_app_id") { _ in }
        let request = (testURLSession.lastDataTask?.originalRequest)!
        let authHeaders = request.allHTTPHeaderFields

        // Assert
        XCTAssertEqual(authHeaders?["Authorization"], expectedAuthHeader)
    }
    
    func testReportOrderSuccess() {
        // Arrange
        let expectation = XCTestExpectation(description: "report order success")
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
        let url = URL(string: "https://api.usebutton.com/v1/mobile-order")!
        
        // Act
        client.reportOrder(parameters: [:], encodedApplicationId: "") { error in
            
            // Assert
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(Data(), response, nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testReportOrderFails() {
        // Arrange
        let expectation = XCTestExpectation(description: "report order fails")
        let testURLSession = TestURLSession()
        let client = Client(session: testURLSession, userAgent: TestUserAgent())
        let url = URL(string: "https://api.usebutton.com/v1/mobile-order")!
        let expectedError = TestError.known
        
        // Act
        client.reportOrder(parameters: [:], encodedApplicationId: "") { error in
            
            // Assert
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? TestError, expectedError)
            
            expectation.fulfill()
        }
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        testURLSession.lastDataTask?.completion(nil, response, expectedError)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
}
