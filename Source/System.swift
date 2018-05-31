//
// System.swift
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

import UIKit

internal protocol SystemType: class {
    var fileManager: FileManagerType { get }
    var calendar: CalendarType { get }
    var adIdManager: ASIdentifierManagerType { get }
    var device: UIDeviceType { get }
    var screen: UIScreenType { get }
    var locale: LocaleType { get }
    var bundle: BundleType { get }
    var currentDate: Date { get }
    var isNewInstall: Bool { get }
    init(fileManager: FileManagerType,
         calendar: CalendarType,
         adIdManager: ASIdentifierManagerType,
         device: UIDeviceType,
         screen: UIScreenType,
         locale: LocaleType,
         bundle: BundleType)
}

internal final class System: SystemType {

    var fileManager: FileManagerType
    var calendar: CalendarType
    var adIdManager: ASIdentifierManagerType
    var device: UIDeviceType
    var screen: UIScreenType
    var locale: LocaleType
    var bundle: BundleType

    var currentDate: Date {
        return Date()
    }

    var isNewInstall: Bool {
        guard let documentsPath = fileManager.urls(for: .documentDirectory,
                                                   in: .userDomainMask).first?.path,
            let attributes = try? fileManager.attributesOfItem(atPath: documentsPath),
            let twelveHoursAgo = calendar.date(byAdding: .hour, value: -12, to: currentDate, wrappingComponents: false),
            let creationDate = attributes[.creationDate] as? Date else {
                return false
        }
        return creationDate.compare(twelveHoursAgo) == ComparisonResult.orderedDescending
    }
    
    init(fileManager: FileManagerType,
         calendar: CalendarType,
         adIdManager: ASIdentifierManagerType,
         device: UIDeviceType,
         screen: UIScreenType,
         locale: LocaleType,
         bundle: BundleType) {
        self.fileManager = fileManager
        self.calendar = calendar
        self.adIdManager = adIdManager
        self.device = device
        self.screen = screen
        self.locale = locale
        self.bundle = bundle
    }
}
