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

struct TestTrusts {
    static let validTrust: SecTrust = {
        var trust: SecTrust?
        SecTrustCreateWithCertificates(TestCertificates.validCertChain as CFTypeRef, nil, &trust)
        return trust!
    }()
    static let invalidTrust: SecTrust = {
        var trust: SecTrust?
        SecTrustCreateWithCertificates(TestCertificates.invalidCertChain as CFTypeRef, nil, &trust)
        return trust!
    }()
    static let unpinnedTrust: SecTrust = {
        var trust: SecTrust?
        SecTrustCreateWithCertificates(TestCertificates.unpinnedCertChain as CFTypeRef, nil, &trust)
        return trust!
    }()
}

class ImplicitTrustEvaluatorTests: XCTestCase {
    
    let evaluator = ImplicitTrustEvaluator()
    
    func testInitialization() {
        // Assert
        XCTAssertNotNil(evaluator)
        XCTAssertEqual(evaluator.publicKeys.count, 0)
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
    
    func testHandleChallenge_invalidTrust_performsDefaultHandling() {
        // Arrange
        let exp = expectation(description: "invalid trust")
        let space = TestURLProtectionSpace()
        space.serverTrust = TestTrusts.invalidTrust
        let challenge = TestURLAuthenticationChallenge(space)
        
        // Act
        evaluator.handleChallenge(challenge) { disposition, _ in
            
            // Assert
            XCTAssertEqual(disposition, URLSession.AuthChallengeDisposition.performDefaultHandling)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func testHandleChallenge_unpinnedChain_performsDefaultHandling() {
        // Arrange
        let exp = expectation(description: "unpinned chain")
        let space = TestURLProtectionSpace()
        space.serverTrust = TestTrusts.unpinnedTrust
        let challenge = TestURLAuthenticationChallenge(space)
        
        // Act
        evaluator.handleChallenge(challenge) { disposition, _ in
            
            // Assert
            XCTAssertEqual(disposition, URLSession.AuthChallengeDisposition.performDefaultHandling)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    func testHandleChallenge_validChain_performsDefaultHandling() {
        // Arrange
        let exp = expectation(description: "valid pinning")
        let space = TestURLProtectionSpace()
        space.serverTrust = TestTrusts.validTrust
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

class TrustEvaluatorTests: XCTestCase {
    
    let evaluator = TrustEvaluator(publicKeys: PEMCertificate.pinnedPublicKeys)
    
    func testInitialization() {
        // Assert
        XCTAssertNotNil(evaluator)
        XCTAssertEqual(evaluator.publicKeys, PEMCertificate.pinnedPublicKeys)
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
        space.serverTrust = TestTrusts.invalidTrust
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
        space.serverTrust = TestTrusts.unpinnedTrust
        let challenge = TestURLAuthenticationChallenge(space)
        
        // Act
        evaluator.handleChallenge(challenge) { disposition, _ in
            
            // Assert
            XCTAssertEqual(disposition, URLSession.AuthChallengeDisposition.performDefaultHandling)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }

    func testHandleChallenge_validChain_performsDefaultHandling() {
        // Arrange
        let exp = expectation(description: "valid pinning")
        let space = TestURLProtectionSpace()
        space.serverTrust = TestTrusts.validTrust
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
