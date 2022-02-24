//
// Response.swift
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

/// Defines the API response structure.
public struct Response {

    public struct Meta: Decodable {

        public enum Status: String, Decodable {
            case ok
            case error
        }

        /// Either 'ok' or 'error' depending on response code.
        public var status: Status

        /// API session identifier.
        public var sessionId: String? = nil
    }

    /// The API error structure.
    public struct APIError: Error, Decodable {
        public var message: String
    }
}

/// Used to convert responses into concrete response types.
public protocol ResponseTypeConvertible: Decodable {
    associatedtype Object

    /// Response metadata. Always present .
    var meta: Response.Meta { get }

    /// Error information. Only for error responses.
    var error: Response.APIError? { get }

    /// Optionally present on successful responses.
    var object: Object? { get }
}

public extension ResponseTypeConvertible {

    /// Decode data into a concrete response type.
    static func from(_ data: Data?) -> Self? {
        guard let data = data else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(Self.self, from: data)
    }
}

/// Concrete reponse implementation omitting Object.
public struct AnyReponse: ResponseTypeConvertible {
    public struct None: Decodable {}

    public var meta: Response.Meta
    public var error: Response.APIError?
    public var object: None?
}
