//
// ActivityRequestBody.swift
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

internal struct ActivityRequestBody {
    let ifa: String?
    let attributionToken: String?
    let name: String
    let products: [ButtonProductCompatible]?
    
    var dictionaryRepresentation: [String: Any] {
        var dict: [String: Any] = ["name": name]
        if let ifa = ifa {
            dict["ifa"] = ifa
        }
        if let attributionToken = attributionToken {
            dict["btn_ref"] = attributionToken
        }
        if let products = products {
            dict["products"] = products.map { product -> [String: Any] in
                var productDict = [String: Any]()
                if let id = product.id {
                    productDict["id"] = id
                }
                if let upc = product.upc {
                    productDict["upc"] = upc
                }
                if let categories = product.categories {
                    productDict["categories"] = categories
                }
                if let name = product.name {
                    productDict["name"] = name
                }
                if let currency = product.currency {
                    productDict["currency"] = currency
                }
                if let url = product.url {
                    productDict["url"] = url
                }
                if let attributes = product.attributes {
                    productDict["attributes"] = attributes
                }
                if product.value != 0 {
                    productDict["value"] = product.value
                }
                if product.quantity != 0 {
                    productDict["quantity"] = product.quantity
                }
                return productDict
            }
        }
        return dict
    }
}
