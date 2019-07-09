//
// ReportOrderRequest.swift
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

internal protocol ReportOrderRequestType {
    var parameters: [String: Any] { get }
    var encodedApplicationId: String { get }
    var retryPolicy: RetryPolicyType { get }
    
    func report(_ request: URLRequest, with session: URLSessionType)
}

internal final class ReportOrderRequest: ReportOrderRequestType {
    
    var parameters: [String: Any]
    var encodedApplicationId: String
    var retryPolicy: RetryPolicyType
    
    required init(parameters: [String: Any], encodedApplicationId: String, retryPolicy: RetryPolicyType = RetryPolicy()) {
        self.parameters = parameters
        self.encodedApplicationId = encodedApplicationId
        self.retryPolicy = retryPolicy
    }
    
    func report(_ request: URLRequest, with session: URLSessionType) {
        
    }
    
}
