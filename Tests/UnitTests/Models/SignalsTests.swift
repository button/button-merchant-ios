/**

 SignalsTests.swift

 Copyright © 2018 Button, Inc. All rights reserved. (https://usebutton.com)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

*/

import XCTest
@testable import ButtonMerchant

class SignalsTests: XCTestCase {

    func testInitialization() {

        let signals = Signals(system: TestSystem())

        XCTAssertEqual(signals.source, "button-merchant")
        XCTAssertEqual(signals.os, "ios")
        XCTAssertEqual(signals.osVersion, "11.0")
        XCTAssertEqual(signals.deviceModel, "iPhone")
        XCTAssertEqual(signals.countryCode, "US")
        XCTAssertEqual(signals.preferredLanguage, "en")
        XCTAssertEqual(signals.screen, "1080x1920")
    }

    func testSerializationToDictionary() {

        let signals = Signals(system: TestSystem())

        XCTAssertEqual(signals.dictionaryRepresentation as NSDictionary, ["source": "button-merchant",
                                                                          "os": "ios",
                                                                          "os_version": "11.0",
                                                                          "device": "iPhone",
                                                                          "country": "US",
                                                                          "language": "en",
                                                                          "screen": "1080x1920"])
    }

    func testTwoSignalsAreEqual() {
        let signals1 = Signals(system: TestSystem())
        let signals2 = Signals(system: TestSystem())
        XCTAssertEqual(signals1, signals2)
    }

    func testTwoDifferingSignalsAreNotEqual() {
        let testDevice = TestDevice()
        testDevice.testModel = "iPod"

        let signals1 = Signals(system: TestSystem())
        let signals2 = Signals(system: TestSystem(fileManager: TestFileManager(),
                                                  calendar: TestCalendar(),
                                                  adIdManager: TestAdIdManager(),
                                                  device: testDevice))

        XCTAssertNotEqual(signals1, signals2)
    }
}
