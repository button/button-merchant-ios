//
// APITests.swift
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

class APITests: XCTestCase {

    func testPostInstallCase() {
        // Arrange
        let expectedBaseURL = URL(string: "https://api.usebutton.com/")!
        let expectedPath = "v1/web/deferred-deeplink"
        let expectedHTTPMethod: HTTPMethod = .post
        let expectedParameters = ["foo": "bar"]
        let expectedHeaders = ["Content-Type": "application/json"]
        let expectedTask: HTTPTask = .request(body: expectedParameters, headers: nil)

        // Act
        let postInstall = API.postInstall(parameters: expectedParameters)

        // Assert
        XCTAssertEqual(postInstall.baseURL, expectedBaseURL)
        XCTAssertEqual(postInstall.path, expectedPath)
        XCTAssertEqual(postInstall.httpMethod, expectedHTTPMethod)
        XCTAssertEqual(postInstall.task, expectedTask)
        XCTAssertEqual(postInstall.headers, expectedHeaders)
    }

    func testActivityCase() {
        // Arrange
        let expectedBaseURL = URL(string: "https://api.usebutton.com/")!
        let expectedPath = "v1/activity/order"
        let expectedHTTPMethod: HTTPMethod = .post
        let expectedParameters = ["foo": "bar"]
        let expectedHeaders = ["Content-Type": "application/json"]
        let expectedTask: HTTPTask = .request(body: expectedParameters, headers: nil)

        // Act
        let postInstall = API.activity(parameters: expectedParameters)

        // Assert
        XCTAssertEqual(postInstall.baseURL, expectedBaseURL)
        XCTAssertEqual(postInstall.path, expectedPath)
        XCTAssertEqual(postInstall.httpMethod, expectedHTTPMethod)
        XCTAssertEqual(postInstall.task, expectedTask)
        XCTAssertEqual(postInstall.headers, expectedHeaders)
    }

    func testOrderCase() {
        // Arrange
        let expectedBaseURL = URL(string: "https://api.usebutton.com/")!
        let expectedPath = "v1/mobile-order"
        let expectedHTTPMethod: HTTPMethod = .post
        let expectedParameters = ["foo": "bar"]
        let expectedHeaders = ["Content-Type": "application/json", "Authorization": "Basic app-id:"]
        let expectedTask: HTTPTask = .request(body: expectedParameters, headers: expectedHeaders)

        // Act
        let postInstall = API.order(parameters: expectedParameters, encodedAppId: "app-id")

        // Assert
        XCTAssertEqual(postInstall.baseURL, expectedBaseURL)
        XCTAssertEqual(postInstall.path, expectedPath)
        XCTAssertEqual(postInstall.httpMethod, expectedHTTPMethod)
        XCTAssertEqual(postInstall.task, expectedTask)
        XCTAssertEqual(postInstall.headers, expectedHeaders)
    }

}
