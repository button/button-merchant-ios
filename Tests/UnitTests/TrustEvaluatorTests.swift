//
// TrustEvaluatorTests.swift
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

class TrustEvaluatorTests: XCTestCase {
    
    var evaluator: TrustEvaluator!
    
    let system = TestSystem()
    let device = TestDevice()
    lazy var validTrust: SecTrust = {
        var trust: SecTrust?
        SecTrustCreateWithCertificates(TestCertificates.validCertChain as CFTypeRef, nil, &trust)
        return trust!
    }()
    lazy var invalidTrust: SecTrust = {
        var trust: SecTrust?
        SecTrustCreateWithCertificates(TestCertificates.invalidCertChain as CFTypeRef, nil, &trust)
        return trust!
    }()
    lazy var unpinnedTrust: SecTrust = {
        var trust: SecTrust?
        SecTrustCreateWithCertificates(TestCertificates.unpinnedCertChain as CFTypeRef, nil, &trust)
        return trust!
    }()
    
    override func setUp() {
        system.device = device
        evaluator = TrustEvaluator(system: system)
    }
    
    func testInitialization_iOS10_certificateStrategy() {
        // Arrange
        device.testSystemVersion = "10.0"
        
        // Act
        evaluator = TrustEvaluator(system: system)
        
        // Assert
        XCTAssertNotNil(evaluator)
        XCTAssertEqual(evaluator.strategy, ValidationStrategy.certificates)
    }
    
    func testInitialization_iOS10_3_publicKeyStrategy() {
        // Arrange
        device.testSystemVersion = "10.3"
        
        // Act
        evaluator = TrustEvaluator(system: system)
        
        // Assert
        XCTAssertNotNil(evaluator)
        XCTAssertEqual(evaluator.strategy, ValidationStrategy.publicKeys)
    }
    
    func testInitialization_iOS12_publicKeyStrategy() {
        // Arrange
        device.testSystemVersion = "12.0"
        
        // Act
        evaluator = TrustEvaluator(system: system)
        
        // Assert
        XCTAssertNotNil(evaluator)
        XCTAssertEqual(evaluator.strategy, ValidationStrategy.publicKeys)
    }
    
    func testHandleChallenge_basicAuthMethod_performsDefaultHandling() {
        // Arrange
        let exp = expectation(description: "basic auth")
        let space = TestURLProtectionSpace()
        space.authenticationMethod = NSURLAuthenticationMethodHTTPBasic
        let challenge = TestURLAuthenticationChallenge(space)
        
        // Act
        evaluator.handleChallenge(challenge) { disposition, _ in
            
            // Assert
            XCTAssertEqual(disposition, URLSession.AuthChallengeDisposition.performDefaultHandling)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func testHandleChallenge_differentHost_performsDefaultHandling() {
        // Arrange
        let exp = expectation(description: "different host")
        let space = TestURLProtectionSpace()
        space.host = "example.com"
        let challenge = TestURLAuthenticationChallenge(space)
        
        // Act
        evaluator.handleChallenge(challenge) { disposition, _ in
            
            // Assert
            XCTAssertEqual(disposition, URLSession.AuthChallengeDisposition.performDefaultHandling)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func testHandleChallenge_invalidTrust_cancelsChallenge() {
        // Arrange
        let exp = expectation(description: "invalid trust")
        let space = TestURLProtectionSpace()
        space.serverTrust = invalidTrust
        let challenge = TestURLAuthenticationChallenge(space)
        
        // Act
        evaluator.handleChallenge(challenge) { disposition, _ in
            
            // Assert
            XCTAssertEqual(disposition, URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func testHandleChallenge_unpinnedChain_cancelsChallenge() {
        // Arrange
        let exp = expectation(description: "unpinned chain")
        let space = TestURLProtectionSpace()
        space.serverTrust = unpinnedTrust
        let challenge = TestURLAuthenticationChallenge(space)
        
        // Act
        evaluator.handleChallenge(challenge) { disposition, _ in
            
            // Assert
            XCTAssertEqual(disposition, URLSession.AuthChallengeDisposition.performDefaultHandling)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }

    func testHandleChallenge_iOS12_performsDefaultHandling() {
        // Arrange
        let exp = expectation(description: "valid pinning iOS 12")
        let space = TestURLProtectionSpace()
        let challenge = TestURLAuthenticationChallenge(space)
        
        // Act
        evaluator.handleChallenge(challenge) { disposition, _ in
            
            // Assert
            XCTAssertEqual(disposition, URLSession.AuthChallengeDisposition.performDefaultHandling)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func testHandleChallenge_iOS10_performsDefaultHandling() {
        // Arrange
        let exp = expectation(description: "valid pinning iOS 10")
        device.testSystemVersion = "10.0"
        evaluator = TrustEvaluator(system: system)
        let space = TestURLProtectionSpace()
        let challenge = TestURLAuthenticationChallenge(space)
        
        // Act
        evaluator.handleChallenge(challenge) { disposition, _ in
            
            // Assert
            XCTAssertEqual(disposition, URLSession.AuthChallengeDisposition.performDefaultHandling)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
}
