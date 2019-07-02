//
// ReportOrder.swift
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

//swiftlint:disable identifier_name

import Foundation

internal protocol APIType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders { get }
}

internal enum API {
    case postInstall(parameters: Parameters)
    case activity(parameters: Parameters)
    case order(parameters: Parameters, encodedAppId: String)
}

extension API: APIType {
    var baseURL: URL {
        guard let url = URL(string: "https://api.usebutton.com/") else {
            fatalError("baseURL could not be configured")
        }
        return url
    }

    var path: String {
        switch self {
        case .postInstall:
            return "v1/web/deferred-deeplink"
        case .activity:
            return "v1/activity/order"
        case .order:
            return "v1/mobile-order"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        default:
            return .post
        }
    }

    var task: HTTPTask {
        switch self {
        case let .postInstall(parameters), let .activity(parameters):
            return .request(body: parameters, headers: nil)
        case .order(let parameters, _):
            return .request(body: parameters, headers: self.headers)
        }
    }

    var headers: HTTPHeaders {
        switch self {
        case .postInstall, .activity:
            return ["Content-Type": "application/json"]
        case .order(_, let encodedAppId):
            return ["Content-Type": "application/json",
                    "Authorization": "Basic \(encodedAppId):"]
        }
    }

}
