//
// RequestTests.swift
//
// Copyright © 2022 Button, Inc. All rights reserved. (https://usebutton.com)
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

class RequestTests: XCTestCase {

    struct AnyRequest: RequestType {
        static var httpMethod: HTTPMethod = .post
        static var path: String = "/any"
    }

    struct TestRequest: RequestType {
        static var httpMethod: HTTPMethod = .post
        static var path: String = "/testing"
        var fooString: String
        var fooBool: Bool
        var fooDict: [String: String]
    }

    func testFormattedBaseURL() {
        XCTAssertEqual(
            Request.formattedBaseURL,
            "https://%@.mobileapi.usebutton.com"
        )
    }

    func testUrlWithAppId() {
        XCTAssertEqual(
            AnyRequest().urlWith(appId: "app-test").absoluteString,
            "https://app-test.mobileapi.usebutton.com/any"
        )
    }

    func testUrlRequestWithCredentialsAddsMethodAndHeaders() {
        let request = AnyRequest()
        let creds = Request.Credentials(userAgent: "Test (UA)", applicationId: "app-test")
        let urlRequest = request.urlRequest(with: creds)
        XCTAssertEqual(urlRequest.httpMethod, AnyRequest.httpMethod.rawValue)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "User-Agent"), "Test (UA)")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Accept"), "application/json")
    }

    func testUrlRequestWithCredentialsNoSession() {
        let request = TestRequest(fooString: "foo", fooBool: true, fooDict: ["foo": "bar"])
        let creds = Request.Credentials(userAgent: "Test (UA)", applicationId: "app-test")
        let urlRequest = request.urlRequest(with: creds)
        XCTAssertEqual(
            urlRequest.httpBody?.toJson(), [
                "application_id": "app-test",
                "foo_string": "foo",
                "foo_bool": true,
                "foo_dict": [
                    "foo": "bar"
                ]
            ]
        )
    }

    func testUrlRequestWithCredentialsWithSession() {
        let request = TestRequest(fooString: "foo", fooBool: true, fooDict: ["foo": "bar"])
        let creds = Request.Credentials(userAgent: "Test (UA)", applicationId: "app-test", sessionId: "sess-test")
        let urlRequest = request.urlRequest(with: creds)
        XCTAssertEqual(urlRequest.httpMethod, TestRequest.httpMethod.rawValue)
        XCTAssertEqual(
            urlRequest.httpBody?.toJson(), [
                "application_id": "app-test",
                "session_id": "sess-test",
                "foo_string": "foo",
                "foo_bool": true,
                "foo_dict": [
                    "foo": "bar"
                ]
            ]
        )
    }
}
