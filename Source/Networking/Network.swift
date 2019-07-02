//
// Router.swift
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

internal protocol NetworkType: class {
    associatedtype EndPoint: APIType
    var session: URLSessionType { get }
    func request(_ route: EndPoint, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

internal class Network<EndPoint: APIType>: NetworkType {

    var session: URLSessionType

    init(session: URLSessionType) {
        self.session = session
    }

    func request(_ route: EndPoint, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let request = urlRequest(from: route)
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            completion(data, response, error)
        })
        task.resume()
    }
}

internal extension Network {

    func urlRequest(from route: EndPoint) -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path))
        request.httpMethod = route.httpMethod.rawValue

        switch route.task {
        case .request(let parameters, let headers):
            if let parameters = parameters {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            }
            var httpHeaders = route.headers
            if let additionalHeaders = headers {
                httpHeaders += additionalHeaders
            }
            for (key, value) in httpHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        return request
    }

}
