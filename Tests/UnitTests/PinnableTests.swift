//
// PinnableTests.swift
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

class PinnableTests: XCTestCase {
    
    func testIsEqual_sameCerts_returnsTrue() {
        // Arrange
        let cert1 = TestCertificates.certNamed("AmazonRootCA1")
        let cert2 = TestCertificates.certNamed("AmazonRootCA1")
        
        // Assert
        XCTAssertTrue(cert1.isEqualTo(cert2))
    }
    
    func testIsEqual_differentCerts_returnsFalse() {
        // Arrange
        let cert1 = TestCertificates.certNamed("AmazonRootCA1")
        let cert2 = TestCertificates.certNamed("AmazonRootCA2")
        
        // Assert
        XCTAssertFalse(cert1.isEqualTo(cert2))
    }
    
    func testIsEqual_certAndKey_returnsFalse() {
        // Arrange
        let cert = TestCertificates.certNamed("AmazonRootCA1")
        let key = TestCertificates.publicKeyNamed("AmazonRootCA1")
        
        // Assert
        XCTAssertFalse(cert.isEqualTo(key))
    }
    
    func testIsEqual_sameKeys_returnsTrue() {
        // Arrange
        let key1 = TestCertificates.publicKeyNamed("AmazonRootCA1")
        let key2 = TestCertificates.publicKeyNamed("AmazonRootCA1")
        
        // Assert
        XCTAssertTrue(key1.isEqualTo(key2))
    }
    
    func testIsEqual_differentKeys_returnsFalse() {
        // Arrange
        let key1 = TestCertificates.publicKeyNamed("AmazonRootCA1")
        let key2 = TestCertificates.publicKeyNamed("AmazonRootCA2")
        
        // Assert
        XCTAssertFalse(key1.isEqualTo(key2))
    }
    
    func testIsEqual_keyAndCert_returnsFalse() {
        // Arrange
        let key = TestCertificates.publicKeyNamed("AmazonRootCA1")
        let cert = TestCertificates.certNamed("AmazonRootCA1")
        
        // Assert
        XCTAssertFalse(key.isEqualTo(cert))
    }
    
}
