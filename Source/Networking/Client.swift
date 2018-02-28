/**

 Client.swift

 Copyright © 2018 Button, Inc. All rights reserved. (https://usebutton.com)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

*/

import Foundation
import UIKit

internal enum Service: String {
    
    case postInstall = "/web/deferred-deeplink"
    
    static var baseURL = "https://api.usebutton.com/v1"
    
    var url: URL {
        return URL(string: Service.baseURL + self.rawValue)!
    }
}

internal enum HTTPMethod: String {
    case post = "POST"
}

internal protocol ClientProtocol: class {
    var session: URLSessionProtocol { get }
    func fetchPostInstallURL(parameters: [String: Any], _ completion: @escaping (URL?, String?) -> Void)
    init(session: URLSessionProtocol)
}

internal final class Client: ClientProtocol {

    var session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func fetchPostInstallURL(parameters: [String: Any], _ completion: @escaping (URL?, String?) -> Void) {
        apiRequest(urlRequest(url: Service.postInstall.url, parameters: parameters),
                   httpMethod: .post) { data in
                    guard let data = data,
                        let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let object = responseDict?["object"] as? [String: Any],
                        let action = object["action"] as? String,
                        let attributionObject = object["attribution"] as? [String: Any] else {
                                completion(nil, nil)
                                return
                    }
                    completion(URL(string: action)!, attributionObject["btn_ref"] as? String)
        }
    }
    
    private func apiRequest(_ request: URLRequest, httpMethod: HTTPMethod, completion: @escaping (Data?) -> Void) {
        dataTask(request: request, method: httpMethod.rawValue, completion: completion)
    }
    
    private func encodeParameters(_ parameters: [String: Any], _ urlRequest: inout URLRequest) {
        guard let methodName = urlRequest.httpMethod,
            let method = HTTPMethod(rawValue: methodName) else {
                return
        }
        switch method {
        case .post:
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }

    private func urlRequest(url: URL, parameters: [String: Any]? = nil) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        if let parameters = parameters {
            encodeParameters(parameters, &urlRequest)
        }
        return urlRequest
    }
    
    private func dataTask(request: URLRequest, method: String, completion: @escaping (Data?) -> Void) {
        var mutableRequest = request
        mutableRequest.httpMethod = method
        
        let dataTask = session.dataTask(with: mutableRequest) { data, response, _  in
            guard let data = data,
                let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                    completion(nil)
                    return
            }
            completion(data)
        }
        dataTask.resume()
    }
}
