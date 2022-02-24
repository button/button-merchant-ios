//
// RetryPolicyTests.swift
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
@testable import Core

class RetryPolicyTests: XCTestCase {
    
    func testInitialization_defaults() {
        // Arrange
        let expectedAttempt = 0
        let expectedRetries = 4
        let expectedTimeoutInterval = 100
        
        // Act
        let policy = RetryPolicy()
        
        // Assert
        XCTAssertEqual(policy.attempt, expectedAttempt)
        XCTAssertEqual(policy.retries, expectedRetries)
        XCTAssertEqual(policy.timeoutIntervalInMs, expectedTimeoutInterval)
    }
    
    func testInitialization() {
        // Arrange
        let expectedRetries = 4
        let expectedTimeoutInterval = 12
        
        // Act
        let policy = RetryPolicy(retries: expectedRetries, timeoutIntervalInMs: expectedTimeoutInterval)
        
        // Assert
        XCTAssertEqual(policy.retries, expectedRetries)
        XCTAssertEqual(policy.timeoutIntervalInMs, expectedTimeoutInterval)
    }
    
    func testNext_increasesAttempt() {
        // Arrange
        let policy = RetryPolicy()
        
        // Act
        policy.next()
        
        // Arrange
        XCTAssertEqual(policy.attempt, 1)
    }
    
    func testDelay() {
        // Arrange
        let policy = RetryPolicy()
        
        // Act/Assert
        policy.next()
        XCTAssertEqual(policy.delay, 0.100)
        policy.next()
        XCTAssertEqual(policy.delay, 0.200)
        policy.next()
        XCTAssertEqual(policy.delay, 0.400)
        policy.next()
        XCTAssertEqual(policy.delay, 0.800)
    }
    
    func testShouldRetry() {
        // Arrange
        let policy = RetryPolicy()

        // Act/Assert
        XCTAssertTrue(policy.shouldRetry)
        policy.next()
        XCTAssertTrue(policy.shouldRetry)
        policy.next()
        XCTAssertTrue(policy.shouldRetry)
        policy.next()
        XCTAssertTrue(policy.shouldRetry)
        policy.next()
        XCTAssertFalse(policy.shouldRetry)
    }
    
}
