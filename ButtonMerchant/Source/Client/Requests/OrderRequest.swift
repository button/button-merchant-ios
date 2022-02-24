//
// OrderRequest.swift
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
import Core

struct OrderRequest: RequestType {
    static var httpMethod: HTTPMethod = .post
    static var path = "/v1/app/order"

    let attributionToken: String?
    let orderId: String
    let currency: String
    let purchaseDate: String
    let customerOrderId: String?
    let lineItems: [Order.LineItem]?
    let customer: Order.Customer?
    let advertisingId: String?

    init(advertisingId: String?,
         attributionToken: String?,
         order: Order) {
        self.advertisingId = advertisingId
        self.attributionToken = attributionToken
        self.orderId = order.id
        self.currency = order.currencyCode
        self.purchaseDate = order.purchaseDate
        self.customerOrderId = order.customerOrderId
        self.lineItems = order.lineItems
        self.customer = order.customer
    }
}
