//
// NetworkTests.swift
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

class NetworkTests: XCTestCase {

    func testInitialization() {
        // Arrange
        let testSession = TestURLSession()
        let testUserAgent = TestUserAgent()

        // Act
        let network = Network<API>(session: testSession, userAgent: testUserAgent)

        // Assert
        XCTAssertEqualReferences(network.session as AnyObject, testSession)
        XCTAssertEqualReferences(network.userAgent as AnyObject, testUserAgent)
    }

    func testRequest_postInstall_createsDataTask() {
        // Arrange
        let testUserAgent = TestUserAgent()
        let expectedParameters = ["foo": "bar"]
        let expectedEndpoint: API = .postInstall(parameters: expectedParameters)
        var expectedHeaders: [String: String] = ["User-Agent": testUserAgent.stringRepresentation]
        expectedHeaders += expectedEndpoint.headers
        let testURLSession = TestURLSession()
        let network = Network<API>(session: testURLSession, userAgent: testUserAgent)

        // Act
        network.request(expectedEndpoint) { _, _, _ in }
        guard let request = network.task?.originalRequest,
            let actualParameters = try? JSONSerialization.jsonObject(with: request.httpBody!) as? [String: String],
            let actualRequestHeaders = request.allHTTPHeaderFields else {
                XCTFail("Request was not created")
                return
        }

        // Assert
        XCTAssertTrue(testURLSession.didCallDataTaskWithRequest)
        XCTAssertEqual(testURLSession.lastDataTask?.originalRequest, request)
        XCTAssertEqual(request.httpMethod, expectedEndpoint.httpMethod.rawValue)
        XCTAssertEqual(actualParameters, expectedParameters)
        XCTAssertEqual(actualRequestHeaders, expectedHeaders)
    }

    func testRequest_activity_createsDataTask() {
        // Arrange
        let testUserAgent = TestUserAgent()
        let expectedParameters = ["foo": "bar"]
        let expectedEndpoint: API = .activity(parameters: expectedParameters)
        var expectedHeaders: [String: String] = ["User-Agent": testUserAgent.stringRepresentation]
        expectedHeaders += expectedEndpoint.headers
        let testURLSession = TestURLSession()
        let network = Network<API>(session: testURLSession, userAgent: testUserAgent)

        // Act
        network.request(expectedEndpoint) { _, _, _ in }
        guard let request = network.task?.originalRequest,
            let actualParameters = try? JSONSerialization.jsonObject(with: request.httpBody!) as? [String: String],
            let actualRequestHeaders = request.allHTTPHeaderFields else {
                XCTFail("Request was not created")
                return
        }

        // Assert
        XCTAssertTrue(testURLSession.didCallDataTaskWithRequest)
        XCTAssertEqual(testURLSession.lastDataTask?.originalRequest, request)
        XCTAssertEqual(request.httpMethod, expectedEndpoint.httpMethod.rawValue)
        XCTAssertEqual(actualParameters, expectedParameters)
        XCTAssertEqual(actualRequestHeaders, expectedHeaders)
    }

    func testRequest_order_createsDataTask() {
        // Arrange
        let testUserAgent = TestUserAgent()
        let expectedParameters = ["foo": "bar"]
        let expectedEncodedAppId = "app-id"
        let expectedEndpoint: API = .order(parameters: expectedParameters, encodedAppId: expectedEncodedAppId)
        var expectedHeaders: [String: String] = ["User-Agent": testUserAgent.stringRepresentation]
        expectedHeaders += expectedEndpoint.headers
        let testURLSession = TestURLSession()
        let network = Network<API>(session: testURLSession, userAgent: testUserAgent)

        // Act
        network.request(expectedEndpoint) { _, _, _ in }
        guard let request = network.task?.originalRequest,
            let actualParameters = try? JSONSerialization.jsonObject(with: request.httpBody!) as? [String: String],
            let actualRequestHeaders = request.allHTTPHeaderFields else {
                XCTFail("Request was not created")
                return
        }

        // Assert
        XCTAssertTrue(testURLSession.didCallDataTaskWithRequest)
        XCTAssertEqual(testURLSession.lastDataTask?.originalRequest, request)
        XCTAssertEqual(request.httpMethod, expectedEndpoint.httpMethod.rawValue)
        XCTAssertEqual(actualParameters, expectedParameters)
        XCTAssertEqual(actualRequestHeaders, expectedHeaders)
    }

}
