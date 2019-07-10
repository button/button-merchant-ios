//
// ReportOrderRequestTests.swift
//
// Copyright © 2019 Button, Inc. All rights reserved. (https://usebutton.com)
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

class ReportOrderRequestTests: XCTestCase {
    
    let session = TestURLSession()
    let policy = TestRetryPolicy()
    var request: ReportOrderRequest!
    var urlRequest: URLRequest!
    
    let url = URL(string: "https://example.com")!
    
    override func setUp() {
        request = ReportOrderRequest(parameters: [:], encodedApplicationId: "", retryPolicy: policy)
        urlRequest = URLRequest(url: url)
    }
    
    func testInitialization() {
        // Arrange
        let params = ["foo": "bar"]
        let appId = "abc123"
        let policy = TestRetryPolicy()
        
        // Act
        let request = ReportOrderRequest(parameters: params, encodedApplicationId: appId, retryPolicy: policy)
        
        // Assert
        XCTAssertEqual(request.parameters as? [String: String], params)
        XCTAssertEqual(request.encodedApplicationId, appId)
        XCTAssertEqualReferences(request.retryPolicy as AnyObject, policy)
    }
    
    func testReport_enqueuesTask() {
        // Act
        request.report(urlRequest, with: session, nil)
        
        // Assert
        XCTAssertEqual(session.lastDataTask?.originalRequest, urlRequest)
    }
    
    func testReport_resumesTaskAfterDelay() {
        // Arrange
        let expectation = XCTestExpectation(description: "resumes task after delay")
        policy.delay = 0.050
        
        // Act
        request.report(urlRequest, with: session, nil)
        
        // Assert
        XCTAssertFalse(self.session.lastDataTask!.didCallResume)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.060) {
            XCTAssertTrue(self.session.lastDataTask!.didCallResume)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testReport_200_doesNotCallNext() {
        // Arrange
        let expectation = XCTestExpectation(description: "200")
        
        request.report(urlRequest, with: session) { error in
            
            // Assert
            XCTAssertNil(error)
            XCTAssertFalse(self.policy.didCallNext)
            
            expectation.fulfill()
        }
        
        // Act
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(nil, response, nil)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testReport_400_doesNotCallNext() {
        // Arrange
        let expectation = XCTestExpectation(description: "400")
        
        request.report(urlRequest, with: session) { error in
            
            // Assert
            XCTAssertNil(error)
            XCTAssertFalse(self.policy.didCallNext)
            
            expectation.fulfill()
        }
        
        // Act
        let response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(nil, response, nil)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testReport_500_callsNext() {
        // Arrange
        request.report(urlRequest, with: session, nil)
        
        // Act
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(nil, response, nil)
        
        // Assert
        XCTAssertTrue(policy.didCallNext)
    }
    
    func testReport_invalidResponse_callsNext() {
        // Arrange
        request.report(urlRequest, with: session, nil)
        
        // Act
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 1, textEncodingName: nil)
        session.lastDataTask?.completion(nil, response, nil)
        
        // Assert
        XCTAssertTrue(policy.didCallNext)
    }
    
    func testReport_500_shouldNotRetry_finishes() {
        // Arrange
        let expectation = XCTestExpectation(description: "no retry finish")
        policy.shouldRetry = false
        
        request.report(urlRequest, with: session) { error in
            
            // Assert
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        // Act
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(nil, response, nil)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testReport_500_shouldRetry_enqueuesAnotherTask() {
        // Arrange
        policy.shouldRetry = true
        request.report(urlRequest, with: session, nil)
        
        // Act
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(nil, response, nil)
        
        // Assert
        XCTAssertEqual(self.session.allDataTasks.count, 2)
    }

}
