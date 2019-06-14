//
// ValidationStrategyTests.swift
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

class ValidationStrategyTests: XCTestCase {
    
    func testPinnableMappingForCertificateStrategy() {
        // Arrange
        let strategy = ValidationStrategy.certificates
        let expectedCerts = TestCertificates.rootCAs
        
        // Act
        let pinnables = strategy.pinnables(from: expectedCerts)
        
        // Assert
        for (index, pinnable) in pinnables.enumerated() {
            // swiftlint:disable:next force_cast
            XCTAssertEqual(pinnable as! SecCertificate, expectedCerts[index])
        }
    }
    
    func testPinnableMappingForPublicKeyStrategy() {
        // Arrange
        let strategy = ValidationStrategy.publicKeys
        let certs = TestCertificates.rootCAs
        let expectedKeys = TestCertificates.rootCAPublicKeys
        
        // Act
        let pinnables = strategy.pinnables(from: certs)
        
        // Assert
        for (index, pinnable) in pinnables.enumerated() {
            // swiftlint:disable:next force_cast
            XCTAssertEqual(pinnable as! SecKey, expectedKeys[index])
        }
    }
}
