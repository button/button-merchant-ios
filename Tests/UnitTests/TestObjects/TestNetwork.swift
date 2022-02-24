//
// TestNetwork.swift
//
// Copyright © 2022 Button, Inc. All rights reserved. (https://usebutton.com)
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
@testable import Core
@testable import ButtonMerchant

class TestNetwork: NetworkType {
    var applicationId: ApplicationId?

    var session: URLSessionType
    var userAgent: String
    var defaults: CoreDefaultsType

    // Output
    var actualRequest: RequestType?
    var actualRetryPolicy: RetryPolicyType?
    var actualCompletion: ((Data?, Error?) -> Void)?
    var didCallClearAllTasks: Bool = false
    var actualEvents: [AppEvent]?
    var actualTime: String?

    required init(
        session: URLSessionType = TestURLSession(),
        userAgent: String = TestUserAgent().stringRepresentation,
        defaults: CoreDefaultsType = TestButtonDefaults(userDefaults: TestUserDefaults())) {
        self.session = session
        self.userAgent = userAgent
        self.defaults = defaults
    }

    func fetch(_ request: RequestType, retryPolicy: RetryPolicyType, completion: ((Data?, Error?) -> Void)?) {
        actualRequest = request
        actualRetryPolicy = retryPolicy
        actualCompletion = completion
    }

    func reportEvents(events: [AppEvent], currentTime: String, ifa: String?, completion: ((Error?) -> Void)?) {
        actualEvents = events
        actualTime = currentTime
    }

    func clearAllTasks() {
        didCallClearAllTasks = true
    }
}
