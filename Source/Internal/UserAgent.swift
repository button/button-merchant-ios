//
// UserAgent.swift
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

internal protocol UserAgentType: class {
    var stringRepresentation: String { get }
    var libraryVersion: String { get }
    var system: SystemType { get }
    init(libraryVersion: String, system: SystemType)
}

internal class UserAgent: UserAgentType {

    static let libraryIdentifier = "com.usebutton.merchant"

    internal var system: SystemType
    internal var libraryVersion: String
    private(set) lazy var stringRepresentation: String = {

        let systemVersion = system.device.systemVersion
        let modelName = system.device.modelName

        let appIdentifier = system.bundle.bundleIdentifier ?? "unknown"
        let appVersion = system.bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let appBuild = system.bundle.infoDictionary?["CFBundleVersion"] as? String ?? "0"

        let scale = system.screen.scale
        let preferredLanguage = type(of: system.locale).preferredLanguages.first
        let language = preferredLanguage?.components(separatedBy: "-").first ?? "en"
        let country = system.locale.regionCode ?? "US"

        return String(format: "%@/%@+1 (iOS %@; %@; %@/%@+%@; Scale/%0.2f; %@-%@)",
                                      UserAgent.libraryIdentifier,
                                      libraryVersion,
                                      systemVersion,
                                      modelName,
                                      appIdentifier,
                                      appVersion,
                                      appBuild,
                                      scale,
                                      language,
                                      country)
    }()

    required init(libraryVersion: String, system: SystemType) {
        self.libraryVersion = libraryVersion
        self.system = system
    }

}
