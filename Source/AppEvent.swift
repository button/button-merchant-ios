//
// AppEvent.swift
//
// Copyright © 2020 Button, Inc. All rights reserved. (https://usebutton.com)
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
	
import UIKit

internal struct AppEvent: Codable {
    let name: String
    let value: [String: String]?
    let attributionToken: String?
    let time: String
    let uuid: String
    let source: Source
    
    enum CodingKeys: String, CodingKey {
        case name, value, time, uuid, source
        case attributionToken = "source_token"
    }
    
    enum Source: String, Codable {
        case button
        case custom
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(time, forKey: .time)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(source, forKey: .source)
        if let attributionToken = attributionToken {
            try container.encode(attributionToken, forKey: .attributionToken)
        }
        if let value = value {
            switch source {
            case .button: try container.encode(value, forKey: .value)
            case .custom: try container.encode(["extra": value], forKey: .value)
            }
        }
    }
}
