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
    let attributionToken: String?
    let name: String
    let products: [ButtonProductCompatible]?
    
    var dictionaryRepresentation: [String: Any] {
        var dict: [String: Any?] = [
            "btn_ref": attributionToken
        ]
        var data: [String: Any?] = ["name": name]
        if let products = products {
            data["products"] = products.map { product -> [String: Any] in
                var productDict: [String: Any?] = [
                    "id": product.id,
                    "upc": product.upc,
                    "categories": product.categories,
                    "name": product.name,
                    "currency": product.currency,
                    "url": product.url,
                    "attributes": product.attributes
                ]
                if product.value != 0 {
                    productDict["value"] = product.value
                }
                if product.quantity != 0 {
                    productDict["quantity"] = product.quantity
                }
                return productDict.compactMapValues { $0 }
            }
        }
        dict["activity_data"] = data
        return dict.compactMapValues { $0 }
    }
}
