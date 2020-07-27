//
// Client.swift
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
import UIKit

internal enum Service: String {
    
    case postInstall = "v1/web/deferred-deeplink"
    case activity = "v1/activity/order"
    case order = "v1/app/order"
    case appEvents = "v1/app/events"
    
    static var baseURL = "https://api.usebutton.com/"
    
    var url: URL {
        return URL(string: Service.baseURL + self.rawValue)!
    }
}

internal protocol ClientType: class {
    var applicationId: String? { get set }
    var session: URLSessionType { get }
    var userAgent: UserAgentType { get }
    func fetchPostInstallURL(parameters: [String: Any], _ completion: @escaping (URL?, String?) -> Void)
    func trackOrder(parameters: [String: Any], _ completion: ((Error?) -> Void)?)
    func reportOrder(orderRequest: ReportOrderRequestType, _ completion: ((Error?) -> Void)?)
    func reportEvents(_ events: [AppEvent], ifa: String?, _ completion: ((Error?) -> Void)?)
    init(session: URLSessionType, userAgent: UserAgentType, defaults: ButtonDefaultsType)
}

internal final class Client: ClientType {
    
    var applicationId: String?
    var session: URLSessionType
    var userAgent: UserAgentType
    var defaults: ButtonDefaultsType
    
    init(session: URLSessionType, userAgent: UserAgentType, defaults: ButtonDefaultsType) {
        self.session = session
        self.userAgent = userAgent
        self.defaults = defaults
    }
    
    func fetchPostInstallURL(parameters: [String: Any], _ completion: @escaping (URL?, String?) -> Void) {
        let request = urlRequest(url: Service.postInstall.url, parameters: parameters)
        enqueueRequest(request: request, completion: { data, _ in
            guard let data = data,
                let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let object = responseDict["object"] as? [String: Any],
                let action = object["action"] as? String,
                let attributionObject = object["attribution"] as? [String: Any] else {
                    completion(nil, nil)
                    return
            }
            completion(URL(string: action)!, attributionObject["btn_ref"] as? String)
        })
    }
    
    func trackOrder(parameters: [String: Any], _ completion: ((Error?) -> Void)?) {
        let request = urlRequest(url: Service.activity.url, parameters: parameters)
        enqueueRequest(request: request) { _, error in
            if let completion = completion {
                completion(error)
            }
        }
    }
    
    func reportOrder(orderRequest: ReportOrderRequestType, _ completion: ((Error?) -> Void)?) {
        let request = urlRequest(url: Service.order.url, parameters: orderRequest.parameters)
        orderRequest.report(request, with: session, completion)
    }
    
    func reportEvents(_ events: [AppEvent], ifa: String?, _ completion: ((Error?) -> Void)?) {
        guard events.count > 0 else {
            if let completion = completion {
                completion("No events to report")
            }
            return
        }
        let body = AppEventsRequestBody(ifa: ifa, events: events)
        let request = urlRequest(url: Service.appEvents.url, parameters: body.dictionaryRepresentation)
        enqueueRequest(request: request) { _, error in
            if let completion = completion {
                completion(error)
            }
        }
    }
}

internal extension Client {
    
    func urlRequest(url: URL, parameters: [String: Any]? = nil) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        var requestParameters = parameters ?? [:]
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(userAgent.stringRepresentation, forHTTPHeaderField: "User-Agent")
        
        if let sessionId = defaults.sessionId {
            requestParameters["session_id"] = sessionId
        }
        
        if let appId = applicationId {
            requestParameters["application_id"] = appId
        }
        
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: requestParameters)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return urlRequest
    }
    
    func enqueueRequest(request: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        let task = session.dataTask(with: request) { data, response, error  in
            guard let data = data,
                let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                    completion(nil, error)
                    return
            }
            
            self.refreshSessionIfAvailable(responseData: data)
            
            completion(data, nil)
        }
        task.resume()
    }
    
    func refreshSessionIfAvailable(responseData: Data?) {
        guard let data = responseData,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let meta = json["meta"] as? [String: Any] else {
                return
        }
        
        let value = meta["session_id"]
        switch value {
        case is String:
            defaults.sessionId = value as? String
        case is NSNull:
            defaults.clearAllData()
        default:
            break
        }
    }
}
