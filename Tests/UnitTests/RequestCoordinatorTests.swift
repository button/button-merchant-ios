//
// RequestCoordinatorTests.swift
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

class RequestCoordinatorTests: XCTestCase {
    
    var session: TestURLSession!
    var coordinator: RequestCoordinator!
    
    override func setUp() {
        session = TestURLSession()
        coordinator = RequestCoordinator(session: session)
    }
    
    func testInitialization() {
        XCTAssertEqualReferences(coordinator.session as AnyObject, session)
    }
    
    func testEnqueueRetriableRequest_createsDataTask() {
        // Arrange
        let request = URLRequest(url: URL(string: "https://usebutton.com")!)
        
        // Act
        coordinator.enqueueRetriableRequest(request: request,
                                            attempt: 0,
                                            maxRetries: 0,
                                            retryIntervalInMS: 0) { _, _ in }
        
        // Assert
        XCTAssertTrue(session.didCallDataTaskWithRequest)
        XCTAssertNotNil(session.lastDataTask)
        XCTAssertEqual(session.lastDataTask?.originalRequest, request)
        XCTAssertTrue(session.lastDataTask!.didCallResume)
        XCTAssertEqual(session.allDataTasks.count, 1)
    }
    
    func testEnqueueRetriableRequest_success() {
        // Arrange
        let expectation = self.expectation(description: "success")
        let url = URL(string: "https://usebutton.com")!
        let expectedData = Data()
        
        // Act
        coordinator.enqueueRetriableRequest(request: URLRequest(url: url), attempt: 0, maxRetries: 0, retryIntervalInMS: 0) { data, error in
            
            // Assert
            XCTAssertNil(error)
            XCTAssertEqual(data, expectedData)
            XCTAssertEqual(self.session.allDataTasks.count, 1)
            
            expectation.fulfill()
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(expectedData, response, nil)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRetriableRequest_failure() {
        // Arrange
        let expectation = self.expectation(description: "failure")
        let url = URL(string: "https://usebutton.com")!
                let expectedError = TestError.known
        
        // Act
        coordinator.enqueueRetriableRequest(request: URLRequest(url: url), attempt: 0, maxRetries: 0, retryIntervalInMS: 0) { data, error in
            
            // Assert
            XCTAssertNil(data)
            XCTAssertEqual(error as? TestError, expectedError)
            XCTAssertEqual(self.session.allDataTasks.count, 1)
            
            expectation.fulfill()
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(nil, response, expectedError)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRetriableRequest_noData_retries() {
        // Arrange
        let expectation = self.expectation(description: "no data retry")
        let url = URL(string: "https://usebutton.com")!
        let request = URLRequest(url: url)
        
        // Act
        coordinator.enqueueRetriableRequest(request: request,
                                            attempt: 0,
                                            maxRetries: 1,
                                            retryIntervalInMS: 0) { _, _ in }
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(nil, response, nil)
        
        DispatchQueue.main.async {
            // Assert
            XCTAssertEqual(self.session.allDataTasks.count, 2)
            XCTAssertTrue(self.session.didCallDataTaskWithRequest)
            XCTAssertNotNil(self.session.lastDataTask)
            XCTAssertEqual(self.session.lastDataTask?.originalRequest, request)
            XCTAssertTrue(self.session.lastDataTask!.didCallResume)
            
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRetriableRequest_400_doesNotRetry() {
        // Arrange
        let expectation = self.expectation(description: "400 no retry")
        let url = URL(string: "https://usebutton.com")!
        let request = URLRequest(url: url)
        
        // Act
        coordinator.enqueueRetriableRequest(request: request,
                                            attempt: 0,
                                            maxRetries: 1,
                                            retryIntervalInMS: 0) { _, _ in }
        
        let response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(Data(), response, nil)
        
        DispatchQueue.main.async {
            // Assert
            XCTAssertEqual(self.session.allDataTasks.count, 1)
            XCTAssertTrue(self.session.didCallDataTaskWithRequest)
            XCTAssertNotNil(self.session.lastDataTask)
            XCTAssertEqual(self.session.lastDataTask?.originalRequest, request)
            XCTAssertTrue(self.session.lastDataTask!.didCallResume)
            
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRetriableRequest_500_retries() {
        // Arrange
        let expectation = self.expectation(description: "500 retry")
        let url = URL(string: "https://usebutton.com")!
        let request = URLRequest(url: url)
        
        // Act
        coordinator.enqueueRetriableRequest(request: request,
                                            attempt: 0,
                                            maxRetries: 1,
                                            retryIntervalInMS: 0) { _, _ in }
        
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(Data(), response, nil)
        
        DispatchQueue.main.async {
            // Assert
            XCTAssertEqual(self.session.allDataTasks.count, 2)
            XCTAssertTrue(self.session.didCallDataTaskWithRequest)
            XCTAssertNotNil(self.session.lastDataTask)
            XCTAssertEqual(self.session.lastDataTask?.originalRequest, request)
            XCTAssertTrue(self.session.lastDataTask!.didCallResume)
            
            expectation.fulfill()
        }
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRetriableRequest_500_retries_500_fails() {
        // Arrange
        let expectation = self.expectation(description: "500 -> 500 fails")
        let url = URL(string: "https://usebutton.com")!
        let request = URLRequest(url: url)
        
        // Act
        coordinator.enqueueRetriableRequest(request: request, attempt: 0, maxRetries: 1, retryIntervalInMS: 0) { data, error in
            
            // Assert
            XCTAssertNil(data)
            XCTAssertEqual(error as? TestError, TestError.known)
            XCTAssertEqual(self.session.allDataTasks.count, 2)
            
            expectation.fulfill()
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(Data(), response, nil)
        
        DispatchQueue.main.async {
            self.session.lastDataTask?.completion(nil, response, TestError.known)
        }
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testEnqueueRetriableRequest_500_retries_200_succeeds() {
        // Arrange
        let expectation = self.expectation(description: "500 -> 500 succeeds")
        let url = URL(string: "https://usebutton.com")!
        let request = URLRequest(url: url)
        let expectedData = Data()
        
        // Act
        coordinator.enqueueRetriableRequest(request: request, attempt: 0, maxRetries: 1, retryIntervalInMS: 0) { data, error in
            
            // Assert
            XCTAssertNil(error)
            XCTAssertEqual(data, expectedData)
            XCTAssertEqual(self.session.allDataTasks.count, 2)
            
            expectation.fulfill()
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        session.lastDataTask?.completion(Data(), response, nil)
        
        DispatchQueue.main.async {
            let successfulResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            self.session.lastDataTask?.completion(expectedData, successfulResponse, nil)
        }
        
        self.wait(for: [expectation], timeout: 2.0)
    }

}
