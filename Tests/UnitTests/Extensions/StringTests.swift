//
// StringTests.swift
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

class StringTests: XCTestCase {

    func testIsPlainTextEmail_arbitraryString_returnsFalse() {
        let email = "not_an_email"

        XCTAssertFalse(email.isPlainTextEmail)
    }

    func testIsPlainTextEmail_hexString_returnsFalse() {
        let email = "314c70b69a726ae7934806b2a0621a0eb193139e38d9bf6134191faa61b7bb29"

        XCTAssertFalse(email.isPlainTextEmail)
    }

    func testIsPlainTextEmail_returnsTrue() {
        let email = "betty@usebutton.com"

        XCTAssertTrue(email.isPlainTextEmail)
    }

}
