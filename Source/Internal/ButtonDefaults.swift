//
// ButtonDefaults.swift
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

internal protocol ButtonDefaultsType: class {
    var userDefaults: UserDefaultsType { get }
    var attributionToken: String? { get set }
    var hasFetchedPostInstallURL: Bool { get set }
    func clearAllData()
    init(userDefaults: UserDefaultsType)
}

/**
 An abstraction for interfacing with Button's user defaults suite.
 */
final internal class ButtonDefaults: ButtonDefaultsType {

    internal enum Keys: String {

        case attributonToken = "attribution-token"
        case postInstallFetchStatus = "post-install-fetched"

        static var prefix = "com.usebutton."

        var key: String {
            return Keys.prefix + self.rawValue
        }
    }

    private(set) var userDefaults: UserDefaultsType
    
    var attributionToken: String? {
        get {
            return userDefaults.value(forKey: Keys.attributonToken.key) as? String
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.attributonToken.key)
            userDefaults.synchronize()
        }
    }

    var hasFetchedPostInstallURL: Bool {
        get {
            return userDefaults.value(forKey: Keys.postInstallFetchStatus.key) as? Bool ?? false
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.postInstallFetchStatus.key)
            userDefaults.synchronize()
        }
    }
    
    required init(userDefaults: UserDefaultsType) {
        self.userDefaults = userDefaults
    }
    
    /**
     Clears all session data by removing the persistent domain for Button.
     */
    func clearAllData() {
        let dictionary = userDefaults.dictionaryRepresentation()
        let keysToClear = dictionary.keys.filter { $0.hasPrefix(Keys.prefix) }
        keysToClear.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
    }
}
