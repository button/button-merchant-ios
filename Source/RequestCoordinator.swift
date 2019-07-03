//
// RequestCoordinator.swift
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

internal protocol RequestCoordinatorType {
    func enqueueRetriableRequest(request: URLRequest,
                                 attempt: Int,
                                 maxRetries: Int,
                                 retryIntervalInMS: Int,
                                 _ completion: @escaping (Data?, Error?) -> Void)
}

internal final class RequestCoordinator: RequestCoordinatorType {
    
    var session: URLSessionType
    
    required init(session: URLSessionType) {
        self.session = session
    }
    
    func enqueueRetriableRequest(request: URLRequest,
                                 attempt: Int,
                                 maxRetries: Int,
                                 retryIntervalInMS: Int,
                                 _ completion: @escaping (Data?, Error?) -> Void) {
        let task = session.dataTask(with: request) { data, response, error  in
            
            var shouldRetry = true
            if let response = response as? HTTPURLResponse,
                data != nil {
                switch response.statusCode {
                case 500...599:
                    shouldRetry = true
                default:
                    shouldRetry = false
                }
            }
            
            guard shouldRetry, attempt + 1 <= maxRetries else {
                completion(data, error)
                return
            }
            
            var delay = retryIntervalInMS
            delay *= attempt == 0 ? 1 : 2 << (attempt - 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay) / 1000.0, execute: {
                self.enqueueRetriableRequest(request: request,
                                             attempt: attempt + 1,
                                             maxRetries: maxRetries,
                                             retryIntervalInMS: retryIntervalInMS,
                                             completion)
            })
        }
        task.resume()
    }
}
