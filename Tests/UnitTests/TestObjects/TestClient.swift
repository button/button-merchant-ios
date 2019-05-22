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
    var testParameters: [String: Any]
    var didCallGetPostInstallLink = false
    var didCallTrackOrder = false

    var session: URLSessionType
    var userAgent: UserAgentType

    var postInstallCompletion: ((URL?, String?) -> Void)?
    var trackOrderCompletion: ((Error?) -> Void)?

    required init(session: URLSessionType, userAgent: UserAgentType) {
        self.session = session
        self.userAgent = userAgent
        self.testParameters = [:]
    }
    
    func fetchPostInstallURL(parameters: [String: Any], _ completion: @escaping (URL?, String?) -> Void) {
        testParameters = parameters
        didCallGetPostInstallLink = true
        postInstallCompletion = completion
    }

    func trackOrder(parameters: [String: Any], _ completion: ((Error?) -> Void)?) {
        testParameters = parameters
        didCallTrackOrder = true
        trackOrderCompletion = completion
    }
}
