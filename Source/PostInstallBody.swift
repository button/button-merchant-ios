//
// PostInstallBody.swift
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

import Foundation

internal struct PostInstallBody: Codable {

    let applicationId: String
    let ifa: String
    let ifaLimited: Bool
    let signals: Signals

    enum CodingKeys: String, CodingKey {
        case applicationId = "application_id"
        case ifa
        case ifaLimited = "ifa_limited"
        case signals
    }

    init(system: SystemType, applicationId: String) {
        self.applicationId = applicationId
        ifa = system.adIdManager.advertisingIdentifier.uuidString
        ifaLimited = !system.adIdManager.isAdvertisingTrackingEnabled
        signals = Signals(system: system)
    }

    internal struct Signals: Codable {

        let source: String
        let os: String
        let osVersion: String
        let deviceModel: String
        let countryCode: String
        let preferredLanguage: String
        let screen: String

        enum CodingKeys: String, CodingKey {
            case source
            case os
            case osVersion = "os_version"
            case deviceModel = "device"
            case countryCode = "country"
            case preferredLanguage = "language"
            case screen
        }

        init(system: SystemType, source: String = "button-merchant", os: String = "ios") {
            self.source = source
            self.os = os
            osVersion = system.device.systemVersion
            deviceModel = system.device.model
            countryCode = system.locale.regionCode ?? "unknown"
            let language = type(of: system.locale).preferredLanguages.first
            preferredLanguage = language?.components(separatedBy: "-").first ?? "en"
            screen = "\(Int(system.screen.nativeBounds.width))x\(Int(system.screen.nativeBounds.height))"
        }
    }
}
