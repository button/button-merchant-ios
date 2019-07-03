//
// UserDefaultsExtensions.swift
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

/**
 The interface through which the library communicates with `UserDefaults`.
 - Note: `UserDefaults` methods are redeclared here as needed.
 */
internal protocol UserDefaultsType: class {
    func setValue(_ value: Any?, forKey key: String)
    func value(forKey: String) -> Any?
    @discardableResult func synchronize() -> Bool
    func dictionaryRepresentation() -> [String: Any]
    func removeObject(forKey defaultName: String)
}

/**
 Conforms the system `UserDefaults` class to the `UserDefaultsProtocol`.
 */
extension UserDefaults: UserDefaultsType {}

/**
 Extends `UserDefaults` with a convenience accessor for Button's
 user defaults suite.
 */
extension UserDefaults {
    
    internal struct Button {
        private static let defaultSuiteName = "com.usebutton.merchant.defaults"
        static var suiteName: String = defaultSuiteName
    }

    static let button = UserDefaults(suiteName: UserDefaults.Button.suiteName)!
}
