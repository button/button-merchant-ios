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

    // MARK: - Test properties

    var actualParameters: Parameters = [:]
    var actualEncodedApplicationId: String?
    var actualPostInstallCompletion: ((URL?, String?) -> Void)?
    var actualTrackOrderCompletion: ((Error?) -> Void)?
    var actualReportOrderCompletion: ((Error?) -> Void)?
    var didCallGetPostInstallLink = false
    var didCallTrackOrder = false
    var didCallReportOrder = false

    // MARK: - Protocol Requirements

    var network: Network<API>
    var responseHandler: NetworkResponseHandlerType

    required init(network: Network<API> = TestNetwork(), responseHandler: NetworkResponseHandlerType = TestNetworkResponseHandler()) {
        self.network = network
        self.responseHandler = responseHandler
    }
    
    func fetchPostInstallURL(parameters: Parameters, _ completion: @escaping (URL?, String?) -> Void) {
        actualParameters = parameters
        didCallGetPostInstallLink = true
        actualPostInstallCompletion = completion
    }

    func trackOrder(parameters: Parameters, _ completion: ((Error?) -> Void)?) {
        actualParameters = parameters
        didCallTrackOrder = true
        actualTrackOrderCompletion = completion
    }
    
    func reportOrder(parameters: Parameters, encodedApplicationId: String, _ completion: ((Error?) -> Void)?) {
        actualParameters = parameters
        actualEncodedApplicationId = encodedApplicationId
        didCallReportOrder = true
        actualReportOrderCompletion = completion
    }
}
