//
// ConfigurationError.swift
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

/**
 Button Merchant Library Configuration Error.
 */
public enum ConfigurationError: Error {

    /**
     Library is not configured with an `applicationId`

     - Note:
     Get your application Id from from the [Button Dashboard](https://app.usebutton.com)
     
     */
    case noApplicationId

    var domain: String {
        return "com.usebutton.merchant.error"
    }

    var localizedDescription: String {
        switch self {
        case .noApplicationId:
            return "Application Id is required via ButtonMerchant.configure(applicationId:)."
        }
    }
}

extension ConfigurationError: Equatable {

    /// :nodoc:
    public static func == (lhs: ConfigurationError, rhs: ConfigurationError) -> Bool {
        return lhs.domain == rhs.domain
            && lhs.localizedDescription == rhs.localizedDescription
    }
}
