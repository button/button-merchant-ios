//
// ButtonMerchantError.swift
//
// Copyright © 2020 Button, Inc. All rights reserved. (https://usebutton.com)
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

/**
 Button Merchant Library Errors.
 */
public enum ButtonMerchantError: Error {
    
    case trackOrderDeprecationError
    case noEventsError
    
    var domain: String {
        return "com.usebutton.merchant.error"
    }
    
    var localizedDescription: String {
        switch self {
        case .trackOrderDeprecationError:
            return "trackOrder(_:) is No longer supported. You can safely remove your usage of this method."
        case .noEventsError:
            return "No events to report"
        }
    }
}

extension ButtonMerchantError: Equatable {
    
    /// :nodoc:
    public static func == (lhs: ButtonMerchantError, rhs: ButtonMerchantError) -> Bool {
        return lhs.domain == rhs.domain
            && lhs.localizedDescription == rhs.localizedDescription
    }
}
