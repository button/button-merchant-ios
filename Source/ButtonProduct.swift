//
// ButtonProduct.swift
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
	
import Foundation

/**
 A protocol that defines the product properties that may be provided when reporting user activity.
 */
@objc public protocol ButtonProductCompatible: class {
    
    /**
     The product identifier.
     */
    var id: String? { get }

    /**
     The UPC (Universal Product Code) of the product.
     */
    var upc: String? { get }

    /**
     A flat array of the names of the categories to which the product belongs.
     */
    var categories: [String]? { get }

    /**
     The name of the product.
     */
    var name: String? { get }

    /**
     The ISO-4217 currency code in which the product's value is reported.
     */
    var currency: String? { get }

    /**
     The value of the order. Includes any discounts, if applicable. Example: 1234 for $12.34.
     */
    var value: Int { get }

    /**
     The quantity of the product.
     */
    var quantity: Int { get }

    /**
     The URL of the product.
     */
    var url: String? { get }

    /**
     Any additional attributes to be included with the product.
     */
    var attributes: [String: String]? { get }
}

/**
 A concrete implementation of the ButtonProductCompatible protocol.
 */
final public class ButtonProduct: NSObject, ButtonProductCompatible {
    public var id: String?
    public var upc: String?
    public var categories: [String]?
    public var name: String?
    public var currency: String?
    public var value: Int = 0
    public var quantity: Int = 0
    public var url: String?
    public var attributes: [String: String]?
}
