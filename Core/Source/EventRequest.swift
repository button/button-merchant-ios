//
// EventRequest.swift
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

public struct AppEvent: Codable {
    public let name: String
    public let time: String
    public let promotionSourceToken: String?
    public let value: [String: String]?
    public let uuid: String

    public init(_ name: String,
                time: String,
                promotionSourceToken: String? = nil,
                value: [String: String]? = nil,
                uuid: String = UUID().uuidString) {
        self.name = name
        self.time = time
        self.promotionSourceToken = promotionSourceToken
        self.value = value
        self.uuid = uuid
    }
}

public struct EventRequest: RequestType {
    public static var httpMethod: HTTPMethod = .post
    public static var path = "/v1/app/events"

    public let ifa: String?
    public let events: [AppEvent]
    public let currentTime: String

    public init(ifa: String? = nil, events: [AppEvent], currentTime: String) {
        self.ifa = ifa
        self.events = events
        self.currentTime = currentTime
    }
}
