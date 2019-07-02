//
// ResultTests.swift
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

class ResultTests: XCTestCase {

    func testEquality_twoSuccessResults_returnsTrue() {
        // Arrange
        let lhsResult: Result<Error> = .success
        let rhsResult: Result<Error> = .success

        // Act & Assert
        XCTAssertTrue(lhsResult == rhsResult)
    }

    func testEquality_lhsSuccess_rhsFailure_returnsFalse() {
        // Arrange
        let lhsResult: Result<Error> = .success
        let rhsResult: Result<Error> = .failure(TestError.known)

        // Act & Assert
        XCTAssertFalse(lhsResult == rhsResult)
    }

    func testEquality_lhsFailure_rhsSuccess_returnsFalse() {
        // Arrange
        let lhsResult: Result<Error> = .failure(TestError.known)
        let rhsResult: Result<Error> = .success

        // Act & Assert
        XCTAssertFalse(lhsResult == rhsResult)
    }

    func testEquality_twoFailureResults_returnTrue() {
        // Arrange
        let lhsResult: Result<Error> = .failure(TestError.known)
        let rhsResult: Result<Error> = .failure(TestError.known)

        // Act & Assert
        XCTAssertTrue(lhsResult == rhsResult)
    }

    func testEquality_twoFailureResults_returnFalse() {
        // Arrange
        let lhsResult: Result<Error> = .failure(TestError.known)
        let rhsResult: Result<Error> = .failure(TestError.unknown)

        // Act & Assert
        XCTAssertFalse(lhsResult == rhsResult)
    }

}
