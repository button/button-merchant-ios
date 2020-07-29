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
    var retryPolicy: RetryPolicyType { get }
    
    func report(_ request: URLRequest, with session: URLSessionType, _ completion: ((Data?, Error?) -> Void)?)
}

internal final class ReportOrderRequest: ReportOrderRequestType {
    
    var parameters: [String: Any]
    var retryPolicy: RetryPolicyType
    
    required init(parameters: [String: Any], retryPolicy: RetryPolicyType = RetryPolicy()) {
        self.parameters = parameters
        self.retryPolicy = retryPolicy
    }
    
    func report(_ request: URLRequest, with session: URLSessionType, _ completion: ((Data?, Error?) -> Void)?) {
        let task = session.dataTask(with: request) { data, response, error in
            var nextAttempt = true
            var networkError: Error? = NetworkError.unknown
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200:
                    networkError = nil
                    nextAttempt = false
                case 500...599:
                    nextAttempt = true
                default:
                    nextAttempt = false
                }
            }
            guard nextAttempt else {
                if let completion = completion {
                    completion(data, networkError)
                }
                return
            }
            
            self.retryPolicy.next()
            
            guard self.retryPolicy.shouldRetry else {
                if let completion = completion {
                    completion(data, networkError)
                }
                return
            }
            
            self.report(request, with: session, completion)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + retryPolicy.delay) {
            task.resume()
        }
    }
    
}
