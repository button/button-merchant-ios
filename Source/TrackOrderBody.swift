//
// TrackOrderBody.swift
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

internal struct TrackOrderBody: Codable {

    let applicationId: String
    let userLocalTime: String
    let attributionToken: String?
    let orderId: String
    let total: Int64
    let currency: String
    let source: String = "merchant-library"

    enum CodingKeys: String, CodingKey {
        case applicationId = "app_id"
        case userLocalTime = "user_local_time"
        case attributionToken = "btn_ref"
        case orderId = "order_id"
        case total
        case currency
        case source
    }

    init(system: SystemType,
         applicationId: String,
         attributionToken: String?,
         order: Order) {

        self.applicationId = applicationId
        userLocalTime = system.currentDate.ISO8601String
        self.attributionToken = attributionToken
        self.orderId = order.id
        self.total = order.amount
        self.currency = order.currencyCode
    }
}
