//
// SessionDelegateTests.swift
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

class TestURLAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        
    }
    
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        
    }
    
    func cancel(_ challenge: URLAuthenticationChallenge) {
        
    }
}

class SessionDelegateTests: XCTestCase {
    
    func testInitialization_iOS10_createsImplicitTrustEvaluator() {
        // Act
        let system = TestSystem()
        let device = TestDevice()
        device.testSystemVersion = "10.0"
        system.device = device
        let delegate = SessionDelegate(system: system)
        
        // Assert
        XCTAssertNotNil(delegate)
        XCTAssertNotNil(delegate.evaluator)
        XCTAssertTrue(delegate.evaluator is ImplicitTrustEvaluator)
    }
    
    func testInitialization_iOS11_createsTrustEvaluator() {
        // Act
        let delegate = SessionDelegate(system: TestSystem())
        
        // Assert
        XCTAssertNotNil(delegate)
        XCTAssertTrue(delegate.evaluator is TrustEvaluator)
    }
    
    func testSessionDidRecieveChallenge_forwardsToEvaluator() {
        // Arrange
        let evaluator = TestTrustEvaluator()
        let delegate = SessionDelegate(system: TestSystem())
        delegate.evaluator = evaluator
        let space = URLProtectionSpace(host: "example.com", port: 343, protocol: nil, realm: nil, authenticationMethod: nil)
        let expectedChallenge = URLAuthenticationChallenge(protectionSpace: space,
                                                           proposedCredential: nil,
                                                           previousFailureCount: 0,
                                                           failureResponse: nil,
                                                           error: nil,
                                                           sender: TestURLAuthenticationChallengeSender())
        
        // Act
        delegate.urlSession(.shared, didReceive: expectedChallenge) { _, _ in
            
        }
        
        // Assert
        // swiftlint:disable:next force_cast
        XCTAssertEqualReferences(evaluator.actualChallenge as! URLAuthenticationChallenge, expectedChallenge)
    }

}
