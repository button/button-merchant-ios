//
// Activity.swift
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
 A protocol through which user activities can be reported.
 */
@objc public protocol Activity: class {
    
    /**
     Report that the user has viewed a product.

     - Parameters:
     - product: The product being viewed.
     */
    func productViewed(_ product: ButtonProductCompatible?)
    
    /**
     Report that the user added a product to their cart.

     - Parameters:
     - product: The product added to the cart.
    */
    func productAddedToCart(_ product: ButtonProductCompatible?)
    
    /**
     Report that the user viewed their cart.

     - Parameters:
     - products: The list of products in the cart.
    */
    func cartViewed(_ products: [ButtonProductCompatible]?)
}
