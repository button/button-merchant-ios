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

}
