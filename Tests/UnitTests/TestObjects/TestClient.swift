//
// TestClient.swift
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
@testable import ButtonMerchant
@testable import Core

class TestClient: ClientType {

    // Test properties
    var testParameters = [String: Any]()
    var didCallGetPostInstallLink = false
    var didCallTrackOrder = false
    var didCallReportOrder = false
    var didCallReportEvents = false
    var didCallProductViewed = false
    var didCallProductAddedToCart = false
    var didCallCartViewed = false
    var didCallClearAllTasks: Bool = false

    var applicationId: ApplicationId?

    var defaults: ButtonDefaultsType
    var system: SystemType
    var network: NetworkType

    var postInstallCompletion: ((URL?, String?) -> Void)?
    var trackOrderCompletion: ((Error?) -> Void)?
    var reportOrderCompletion: ((Error?) -> Void)?
    
    var actualEvents: [AppEvent]?
    var actualOrder: Order?
    var actualReportEventsCompletion: ((Error?) -> Void)?
    var actualProduct: ButtonProductCompatible?
    var actualProducts: [ButtonProductCompatible]?
    
    required init(defaults: ButtonDefaultsType, system: SystemType, network: NetworkType) {
        self.defaults = defaults
        self.system = system
        self.network = network
    }
    
    func fetchPostInstallURL(_ completion: @escaping (URL?, String?) -> Void) {
        didCallGetPostInstallLink = true
        postInstallCompletion = completion
    }

    func reportOrder(_ order: Order, _ completion: ((Error?) -> Void)?) {
        didCallReportOrder = true
        actualOrder = order
        reportOrderCompletion = completion
    }

    func reportEvents(_ events: [AppEvent], _ completion: ((Error?) -> Void)?) {
        didCallReportEvents = true
        actualEvents = events
        actualReportEventsCompletion = completion
    }

    func reportActivity(_ name: String, products: [ButtonProduct]?) {
        
    }

    func productViewed(_ product: ButtonProductCompatible?) {
        didCallProductViewed = true
        actualProduct = product
    }
    
    func productAddedToCart(_ product: ButtonProductCompatible?) {
        didCallProductAddedToCart = true
        actualProduct = product
    }
    
    func cartViewed(_ products: [ButtonProductCompatible]?) {
        didCallCartViewed = true
        actualProducts = products
    }

    func clearAllTasks() {
        didCallClearAllTasks = true
    }
}
