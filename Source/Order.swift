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
Represents an order placed by the user to be reported using `ButtonMerchant.reportOrder(order)`.
 */
@objcMembers
@objc(BTNOrder) final public class Order: NSObject, Codable {

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
     The customer-facing order id.
     */
    public var customerOrderId: String?

    /**
     The customer related to the order
     */
    public var customer: Customer?
    
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
    @objcMembers
    @objc(BTNCustomer) final public class Customer: NSObject, Codable {
        
        /**
         The id for the transacting customer in your system (required).
         */
        let id: String

        /**
         - Important:
           Deprecated. This property is a no-op. Data is not collected.
        */
        @available(*, deprecated, message: "Setting this property is a no-op. Data is not collected.")
        public var email: String? {
            set {}
            get { return nil }
        }
        
        /**
         A flag indicating whether the customer is new (or not).
         */
        public var isNew: Bool?

        /**
         Initializes a customer object with the passed parameters.

         - Parameters:
         - id: The id for your customer (required).
         */
        @objc public init(id: String) {
            self.id = id
        }

        enum CodingKeys: String, CodingKey {
            case id
            case isNew = "is_new"
        }
    }

    /**
     Represents a line item in the order.
     */
    @objcMembers
    @objc(LineItem) final public class LineItem: NSObject, Codable {

        /**
         The unique identifier for this line item,
         within the scope of this order. (required).
         */
        let id: String

        /**
         The total price of all items bought in a particular line item (required).
         (e.g. if 3 bananas were purchased for $3.00 each, total would be 900).
         */
        let total: Int64

        /**
         The number of unique units represented by this line item (default is 1).
         */
        public var quantity: Int

        /**
         Text describing the line item.
         */
        public var itemDescription: String?

        /**
         The Stock Keeping Unit of the line item.
         */
        public var sku: String?

        /**
         The Universal Product Code of the line item.
         */
        public var upc: String?

        /**
         The category of the line item.
         An ordered list of strings, starting with the topmost (or most general) category.
         */
        public var category: [String]?

        /**
         A key/value store for strings to specify additional information about a line item.
         */
        public var attributes: [String: String]?

        /**
         An array of the line item details that comprise the order

         - Parameters:
            - id: The unique identifier for this line item, within the scope of this order.
                          This must be unique across all line-items within the order.
                          We suggest using the SKU or UPC of the product. (required)
            - total: The total price of all items bought in a particular line item. (required)
         */
        @objc public init(id: String, total: Int64) {
            self.id = id
            self.total = total
            self.quantity = 1
        }

        enum CodingKeys: String, CodingKey {
            case id = "identifier"
            case total
            case quantity
            case itemDescription = "description"
            case sku
            case upc
            case category
            case attributes
        }
    }

    // MARK: - Deprecations

    /**
     Deprecated.

     This field is no longer supported and will be removed in a future release.
     */
    @available(*, deprecated)
    private(set) var amount: Int64 = 0

    /**
     Deprecated.

     If you're migrating to client side order reporting, please use init(id:purchaseDate:lineItems:) instead.
     */
    @available(*, deprecated, message: "Use init(id:purchaseDate:lineItems:) instead")
    @objc public init(id: String, amount: Int64 = 0, currencyCode: String = "USD") {
        self.id = id
        self.amount = amount
        self.currencyCode = currencyCode
        // Declare default values to keep a consistent API for the new interface.
        self.purchaseDate = Date().ISO8601String
        self.lineItems = []
    }
}
