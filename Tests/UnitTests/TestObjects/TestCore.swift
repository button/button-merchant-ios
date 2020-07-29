//
// TestCore.swift
//
// Copyright © 2018 Button. All rights reserved. (https://usebutton.com)
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

class TestCore: CoreType {

    // Test properties
    var testToken: String?
    var testUrl: URL?
    var testShouldFetchPostInstallURL: Bool?
    var testOrder: Order?
    var didCallTrackIncomingURL = false
    var didCallClearAllData = false
    var didCallFetchPostInstallURL = false
    
    var applicationId: ApplicationId?
    var buttonDefaults: ButtonDefaultsType
    var client: ClientType
    var system: SystemType
    var notificationCenter: NotificationCenterType
    
    var attributionToken: String? {
        get {
            return testToken
        }
        set {
            testToken = newValue
        }
    }

    var shouldFetchPostInstallURL: Bool {
        return testShouldFetchPostInstallURL ?? true
    }
    
    required init(buttonDefaults: ButtonDefaultsType,
                  client: ClientType,
                  system: SystemType,
                  notificationCenter: NotificationCenterType) {
        self.buttonDefaults = buttonDefaults
        self.client = client
        self.system = system
        self.notificationCenter = notificationCenter
    }
    
    func handlePostInstallURL(_ completion: @escaping (URL?, Error?) -> Void) {
        didCallFetchPostInstallURL = true
        completion(nil, nil)
    }

    func trackOrder(_ order: Order, _ completion: ((Error?) -> Void)?) {
        testOrder = order
    }
    
    func reportOrder(_ order: Order, _ completion: ((Error?) -> Void)?) {
        testOrder = order
    }
    
    func trackIncomingURL(_ url: URL) {
        testUrl = url
    }
    
    func clearAllData() {
        didCallClearAllData = true
    }
    
}
