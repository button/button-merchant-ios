//
// Request.swift
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

public enum HTTPMethod: String {
    case post = "POST"
}

/// Defines the request structure.
public protocol RequestType: Codable {

    /// The HTTP method.
    static var httpMethod: HTTPMethod { get }

    /// The path to endpoint.
    static var path: String { get }
}

extension RequestType {

    /// Creates a URLRequest from a concrete RequestType.
    func urlRequest(with credentials: Request.Credentials) -> URLRequest {
        var urlRequest = URLRequest(url: urlWith(appId: credentials.applicationId))
        urlRequest.httpMethod = Self.httpMethod.rawValue
        urlRequest.setValue(credentials.userAgent, forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        var json = toJson() ?? [:]
        json["application_id"] = credentials.applicationId
        json["session_id"] = credentials.sessionId

        urlRequest.httpBody = json.toData()
        return urlRequest
    }

    func urlWith(appId: String) -> URL {
        return URL(string: String(format: Request.formattedBaseURL, appId) + Self.path)!
    }
}

struct Request {

    static let formattedBaseURL = "https://%@.mobileapi.usebutton.com"

    struct Credentials {
        var userAgent: String
        var applicationId: String
        var sessionId: String? = nil
    }
}
