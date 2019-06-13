//
// Order.swift
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

/**
Represents an order placed by the user to be tracked using `ButtonMerchant.trackOrder(order)`.
 */
@objcMembers final public class Order: NSObject, Codable {

    /**
     The order identifier (required).
     */
    let id: String

    /**
     The purchase date for the order (ISO-8601 string).
     */
    let purchaseDate: String

    /**
     A list of the line item details that comprise the order
     */
    let lineItems: [LineItem]

    /**
     The ISO 4217 currency code (default is USD).
     */
    public var currencyCode: String = "USD"

    /**
     The customer-facing order id
     */
    public var customerOrderId: String?

    /**
     The customer related to the order
     */
    public var customer: Customer?

    /**
     The total order value in pennies (e.g. 3999 for $39.99)
     or the smallest decimal unit of the currency. (default is 0)
     */
    @available(*, deprecated)
    private(set) var amount: Int64 = 0

    /**
     Represents a line item in the order.
     */
    public class LineItem: NSObject, Codable {
        
    }
    
    /**
     Initializes an order object with the passed parameters.

     - Parameters:
        - id: The order identifier (required).
        - amount: The total order value in pennies or the
                  smallest decimal unit of the currency (e.g. 3999 for $39.99).
        - currencyCode: The ISO 4217 currency code (default is USD).
     */
    @available(*, deprecated, message: "Use init(id:currencyCode:purchaseDate:customerOrderId:lineItems:customer:) instead")
    @objc public init(id: String, amount: Int64 = 0, currencyCode: String = "USD") {
        self.id = id
        self.amount = amount
        self.currencyCode = currencyCode
        // Declare default values to keep a consistent API for the new interface.
        self.purchaseDate = Date().ISO8601String
        self.lineItems = []
    }
    
    /**
     Initializes an order object with the passed parameters.
     
     - Parameters:
     - id: The order identifier (required).
     - purchaseDate: The date of the purchase for the order.
     - lineItems: A list of the line item details that comprise the order.
     */
    @objc public init(id: String, purchaseDate: Date, lineItems: [LineItem]) {
        self.id = id
        self.purchaseDate = purchaseDate.ISO8601String
        self.lineItems = lineItems
    }

    enum CodingKeys: String, CodingKey {
        case id = "order_id"
        case amount
        case currencyCode = "currency"
        case purchaseDate = "purchase_date"
        case customerOrderId = "customer_order_id"
        case lineItems = "line_items"
        case customer
    }
    
    /**
     Represents a customer in the order.
     */
    public class Customer: NSObject, Codable {
        
        /**
         The id for the transacting customer in your system (required).
         */
        let id: String
        
        /**
         The email of the transacting customer.
         */
        let email: String?
        
        /**
         The SHA-256 hash of the transacting customer’s lowercase email, as a 64-character hex string.
         The value of the e-mail address must be converted to lowercase before computing the hash.
         The hash itself may use uppercase or lowercase hex characters.
         */
        let emailSha256: String?
        
        /**
         The customer’s IDFA.
         */
        let advertisingId: String?
        
        /**
         Initializes a customer object with the passed parameters.
         
         - Parameters:
         - id: The id for the transacting customer in your system (required).
         - email: The email of the transacting customer.
         - advertisingId: The customer’s IDFA.
         */
        @objc public init(id: String, email: String?, advertisingId: String? = nil) {
            self.id = id
            self.email = email?.lowercased()
            self.advertisingId = advertisingId
            self.emailSha256 = nil
        }
        
        /**
         Initializes a customer object with the passed parameters.
         
         - Parameters:
         - id: The id for the transacting customer in your system (required).
         - emailSha256: The SHA-256 hash of the transacting customer’s lowercase email, as a 64-character hex string.
                        The value of the e-mail address must be converted to lowercase before computing the hash.
                        The hash itself may use uppercase or lowercase hex characters.
         - advertisingId: The customer’s IDFA.
         */
        @objc public init(id: String, emailSha256: String?, advertisingId: String? = nil) {
            self.id = id
            self.emailSha256 = emailSha256
            self.advertisingId = advertisingId
            self.email = nil
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case email
            case emailSha256 = "email_sha256"
            case advertisingId = "advertising_id"
        }
    }

}
