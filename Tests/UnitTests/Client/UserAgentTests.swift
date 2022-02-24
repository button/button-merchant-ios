//
// UserAgentTests.swift
//
// Copyright © 2018 Button, Inc. All rights reserved. (https://usebutton.com)
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

class UserAgentTests: XCTestCase {

    func testUserAgentStringIsCorrectOnInitialization() {
        // Arrange
        let expectedUserAgentString = "com.usebutton.merchant/0.1.0-test+1 (iOS 11.0; iPhone10,1; com.usebutton.app/1.0.1+1; Scale/2.00; en-US)"
        let testAppBundle = TestBundle()
        let testSystem = TestSystem(bundle: testAppBundle)
        let userAgent = UserAgent(libraryVersion: "0.1.0-test", system: testSystem)

        // Act
        let actualUserAgentString = userAgent.stringRepresentation

        // Assert
        XCTAssertEqual(actualUserAgentString, expectedUserAgentString)
    }

}
