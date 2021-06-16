//
// TestSystem.swift
//
// Copyright © 2018 Button. All rights reserved. (https://usebutton.com)
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

import UIKit
@testable import ButtonMerchant

final class TestSystem: SystemType {

    //Test Properties
    var testIsNewInstall = false
    var testCurrentDate: Date

    // SystemType
    var includesIFA: Bool
    var fileManager: FileManagerType
    var calendar: CalendarType
    var adIdManager: ASIdentifierManagerType
    var device: UIDeviceType
    var screen: UIScreenType
    var locale: LocaleType
    var bundle: BundleType
    
    var advertisingId: String? = "00000000-0000-0000-0000-000000000000"
    
    var currentDate: Date {
        return testCurrentDate
    }

    var isNewInstall: Bool {
        return testIsNewInstall
    }

    init(fileManager: FileManagerType = TestFileManager(),
         calendar: CalendarType = TestCalendar(),
         adIdManager: ASIdentifierManagerType = TestAdIdManager(),
         device: UIDeviceType = TestDevice(),
         screen: UIScreenType = TestScreen(),
         locale: LocaleType = TestLocale(),
         bundle: BundleType = TestBundle()) {

        // Fix timezone to UTC for tests.
        Date.ISO8601Formatter.timeZone = TimeZone(identifier: "UTC")
        testCurrentDate = Date.ISO8601Formatter.date(from: "2018-01-23T12:00:00Z")!
        
        self.fileManager = fileManager
        self.calendar = calendar
        self.adIdManager = adIdManager
        self.device = device
        self.screen = screen
        self.locale = locale
        self.bundle = bundle
        self.includesIFA = true
    }
}
