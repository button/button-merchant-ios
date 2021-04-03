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

class TestClient: ClientType {

    // Test properties
    var testReportOrderRequest: ReportOrderRequestType?
    var testParameters: [String: Any]
    var didCallGetPostInstallLink = false
    var didCallTrackOrder = false
    var didCallReportOrder = false
    var didCallReportEvents = false
    var didCallProductViewed = false
    var didCallProductAddedToCart = false
    var didCallCartViewed = false

    var isConfigured: Bool = true
    var applicationId: ApplicationId?
    
    var session: URLSessionType
    var userAgent: UserAgentType
    var defaults: ButtonDefaultsType
    var system: SystemType
    var pendingTasks = [PendingTask]()

    var postInstallCompletion: ((URL?, String?) -> Void)?
    var trackOrderCompletion: ((Error?) -> Void)?
    var reportOrderCompletion: ((Error?) -> Void)?
    
    var actualEvents: [AppEvent]?
    var actualIFA: String?
    var actualReportEventsCompletion: ((Error?) -> Void)?
    var actualProduct: ButtonProductCompatible?
    var actualProducts: [ButtonProductCompatible]?
    
    required init(session: URLSessionType, userAgent: UserAgentType, defaults: ButtonDefaultsType, system: SystemType) {
        self.session = session
        self.userAgent = userAgent
        self.defaults = defaults
        self.system = system
        self.testParameters = [:]
    }
    
    func fetchPostInstallURL(_ completion: @escaping (URL?, String?) -> Void) {
        didCallGetPostInstallLink = true
        postInstallCompletion = completion
    }

    func trackOrder(parameters: [String: Any], _ completion: ((Error?) -> Void)?) {
        testParameters = parameters
        didCallTrackOrder = true
        trackOrderCompletion = completion
    }
    
    func reportOrder(orderRequest: ReportOrderRequestType, _ completion: ((Error?) -> Void)?) {
        didCallReportOrder = true
        testReportOrderRequest = orderRequest
        reportOrderCompletion = completion
    }
    
    func reportEvents(_ events: [AppEvent], ifa: String?, _ completion: ((Error?) -> Void)?) {
        didCallReportEvents = true
        actualEvents = events
        actualIFA = ifa
        actualReportEventsCompletion = completion
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
}
