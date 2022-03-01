//
// ResponseTests.swift
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
@testable import ButtonMerchant

struct TestResponse: ResponseTypeConvertible {
    struct Body: Codable {
        var fooString: String
        var fooBool: Bool
        var fooDict: [String: String]
    }
    var meta: Response.Meta
    var error: Response.APIError?
    var object: Body?
}

class ResponseTests: XCTestCase {

    func testDecodesOKResponse() {
        let response = TestResponse.from([
            "meta": [
                "status": "ok"
            ],
            "object": [
                "foo_string": "bar",
                "foo_bool": true,
                "foo_dict": [
                    "foo": "bar"
                ]
            ]
        ].toData())
        XCTAssertEqual(response?.meta.status, Response.Meta.Status.ok)
        XCTAssertEqual(response?.object?.fooString, "bar")
        XCTAssertTrue(response!.object!.fooBool)
        XCTAssertEqual(response?.object?.fooDict, [
            "foo": "bar"
        ])
    }

    func testDecodesErrorResponse() {
        let response = TestResponse.from([
            "meta": [
                "status": "error"
            ],
            "error": [
                "message": "Client not wearing jumper."
            ]
        ].toData())
        XCTAssertEqual(response?.meta.status, Response.Meta.Status.error)
        XCTAssertEqual(response?.error?.message, "Client not wearing jumper.")
    }
}
