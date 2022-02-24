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

public protocol CoreDefaultsType: AnyObject {
    var userDefaults: UserDefaultsType { get }

    /// Current session identifier.
    var sessionId: String? { get set }

    init(userDefaults: UserDefaultsType)
    func set(_ value: Any?, for key: Defaults.PrefixedKey)
    func value(for key: Defaults.PrefixedKey) -> Any?

    /// Clears all session data by removing all known keys.
    func clearAllData()
}

/**
 An abstraction for interfacing Button's user defaults suite.
 */
public class Defaults: CoreDefaultsType {

    private(set) public var userDefaults: UserDefaultsType

    public var sessionId: String? {
        get {
            return value(for: Key.sessionId.prefixed) as? String
        }
        set {
            set(newValue, for: Key.sessionId.prefixed)
        }
    }

    required public init(userDefaults: UserDefaultsType) {
        self.userDefaults = userDefaults
    }
}

extension Defaults {

    enum Key: String {
        case sessionId = "session-id"

        var prefixed: PrefixedKey {
            return PrefixedKey(rawValue: rawValue)
        }
    }

    public struct PrefixedKey {
        static let prefix = "com.usebutton."
        public var rawValue: String
        public init(rawValue: String) {
            self.rawValue = "\(Self.prefix)\(rawValue)"
        }
    }
}

extension Defaults {

    public func set(_ value: Any?, for key: Defaults.PrefixedKey) {
        userDefaults.setValue(value, forKey: key.rawValue)
        userDefaults.synchronize()
    }

    public func value(for key: Defaults.PrefixedKey) -> Any? {
        return userDefaults.value(forKey: key.rawValue)
    }

    public func clearAllData() {
        let dictionary = userDefaults.dictionaryRepresentation()
        let keysToClear = dictionary.keys.filter { $0.hasPrefix(PrefixedKey.prefix) }
        keysToClear.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
    }
}
