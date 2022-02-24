//
// RetryPolicy.swift
//
// Copyright © 2019 Button, Inc. All rights reserved. (https://usebutton.com)
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

public protocol RetryPolicyType {
    var shouldRetry: Bool { get }
    var delay: Double { get }
    func next()
    func execute(_ block: @escaping () -> ())
}

public final class RetryPolicy: RetryPolicyType {
    var attempt = 0
    var retries: Int
    var timeoutIntervalInMs: Int
    
    public var shouldRetry: Bool {
        return attempt < retries
    }
    
    public var delay: Double {
        guard attempt > 0 else {
            return 0.0
        }
        return exp2(Double(attempt - 1)) * Double(timeoutIntervalInMs) / 1000.0
    }
    
    public required init(retries: Int = 4, timeoutIntervalInMs: Int = 100) {
        self.retries = retries
        self.timeoutIntervalInMs = timeoutIntervalInMs
    }
    
    public func next() {
        attempt += 1
    }

    public func execute(_ block: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            block()
        }
    }
}
