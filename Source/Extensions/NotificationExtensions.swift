// 
// NotificationExtensions.swift
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

@objc extension ButtonMerchant {
    /// Posted when the stored `attributionToken` is updated from an inbound Button attributed URL.
    public static let AttributionTokenDidChangeNotification: NSString = "com.usebutton.merchant.notification.name.button.AttributionTokenDidChange"
    /// User info dictionary key representing the new `attributionToken` associated with the notification.
    public static let AttributionTokenKey: NSString = "com.usebutton.merchant.notification.key.newToken"
}

extension Notification {

    /// Used as a namespace for all Button related `Notification` user info dictionary keys.
    public struct Key {
        
        /// User info dictionary key representing the new `attributionToken` associated with the notification.
        public static let NewToken = ButtonMerchant.AttributionTokenKey as String
    }
}

extension Notification.Name {
    
    /// Used as a namespace for all Button related notifications.
    public struct Button {
        
        /// Posted when the stored `attributionToken` is updated from an inbound Button attributed URL.
        public static let AttributionTokenDidChange: Notification.Name = {
            return Notification.Name(rawValue: ButtonMerchant.AttributionTokenDidChangeNotification as String)
        }()
    }
}
