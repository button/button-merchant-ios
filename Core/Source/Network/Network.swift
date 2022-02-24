//
// Client.swift
//
// Copyright © 2022 Button, Inc. All rights reserved. (https://usebutton.com)
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

public protocol NetworkType {
    var applicationId: ApplicationId? { get set }
    init(session: URLSessionType, userAgent: String, defaults: CoreDefaultsType)
    func fetch(_ request: RequestType, retryPolicy: RetryPolicyType, completion: ((Data?, Error?) -> Void)?)
    func clearAllTasks()
}

public class Network: NetworkType {

    public var applicationId: ApplicationId? = nil {
        didSet {
            if applicationId != nil {
                flushPendingTasks()
            }
        }
    }

    var userAgent: String
    var defaults: CoreDefaultsType
    var session: URLSessionType
    var pendingTasks = [PendingTask]()

    public required init(session: URLSessionType, userAgent: String, defaults: CoreDefaultsType) {
        self.session = session
        self.userAgent = userAgent
        self.defaults = defaults
    }

    public func clearAllTasks() {
        pendingTasks.removeAll()
    }

    public func fetch(_ request: RequestType,
                      retryPolicy: RetryPolicyType,
                      completion: ((Data?, Error?) -> Void)?) {
        guard let appId = applicationId else {
            pendingTasks.append(PendingTask(request: request, retryPolicy: retryPolicy, completion: completion))
            return
        }

        let creds = Request.Credentials(userAgent: userAgent,
                                        applicationId: appId.rawValue,
                                        sessionId: defaults.sessionId)

        let urlRequest = request.urlRequest(with: creds)
        execute(urlRequest, retryPolicy: retryPolicy) { [self] data, error in
            refreshSession(data)
            OperationQueue.main.addOperation {
                completion?(data, error)
            }
        }
    }

    private func execute(_ request: URLRequest,
                         retryPolicy: RetryPolicyType,
                         _ completion: ((Data?, Error?) -> Void)?) {

        let task = session.dataTask(with: request) { [self] data, response, error in
            guard let response = response as? HTTPURLResponse else {
                completion?(data, error)
                return
            }

            if 500...599 ~= response.statusCode {
                retryPolicy.next()
                guard retryPolicy.shouldRetry else {
                    completion?(data, NetworkError.unknown)
                    return
                }

                execute(request, retryPolicy: retryPolicy, completion)
            }
            else {
                completion?(data, error)
            }
        }

        retryPolicy.execute {
            task.resume()
        }
    }

    private func refreshSession(_ data: Data?) {
        guard let data = data,
        let sessionId = AnyReponse.from(data)?.meta.sessionId else {
            defaults.clearAllData()
            return
        }
        defaults.sessionId = sessionId
    }

    private func flushPendingTasks() {
        pendingTasks.forEach { task in
            fetch(task.request, retryPolicy: task.retryPolicy, completion: task.completion)
        }
        pendingTasks.removeAll()
    }
}

/// Tasks waiting for an Application Id
extension Network {
    internal struct PendingTask {
        var request: RequestType
        var retryPolicy: RetryPolicyType
        var completion: ((Data?, Error?) -> Void)?
    }
}

/// NetworkType Argument Defaults
public extension NetworkType {
    func fetch(_ request: RequestType,
               retryPolicy: RetryPolicyType = RetryPolicy(retries: 0),
               completion: ((Data?, Error?) -> Void)? = nil) {
        fetch(request, retryPolicy: retryPolicy, completion: completion)
    }
}
