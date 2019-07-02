//
// NetworkResponseHandlerTests.swift
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

class NetworkResponseHandlerTests: XCTestCase {

    func testHandleResponse_successStatussCode_returnsSuccessResult() {
        // Arrange
        let response = TestHTTPURLResponse()
        let responseHandler = NetworkResponseHandler()
        let expectedResult: Result<Error> = .success

        // Act
        let actualResult = responseHandler.handleResponse(response)

        // Assert
        XCTAssertEqual(actualResult, expectedResult)
    }

    func testHandleResponse_rateLimitStatusCode_returnRateLimitError() {
        // Arrange
        let response = TestHTTPURLResponse(statusCode: 429)
        let responseHandler = NetworkResponseHandler()
        let expectedResult: Result<Error> = .failure(ClientError.rateLimited)

        // Act
        let actualResult = responseHandler.handleResponse(response)

        // Assert
        XCTAssertEqual(actualResult, expectedResult)
    }

    func testHandleResponse_successServerStatusCode_returnsBadRequestError() {
        // Arrange
        let response = TestHTTPURLResponse(statusCode: 501)
        let responseHandler = NetworkResponseHandler()
        let expectedResult: Result<Error> = .failure(ClientError.badRequest)

        // Act
        let actualResult = responseHandler.handleResponse(response)

        // Assert
        XCTAssertEqual(actualResult, expectedResult)
    }

    func testHandleResponse_defaultStatusCode_returnFailedError() {
        // Arrange
        let response = TestHTTPURLResponse(statusCode: 401)
        let responseHandler = NetworkResponseHandler()
        let expectedResult: Result<Error> = .failure(ClientError.failed)

        // Act
        let actualResult = responseHandler.handleResponse(response)

        // Assert
        XCTAssertEqual(actualResult, expectedResult)
    }

}
