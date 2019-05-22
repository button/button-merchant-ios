//
// Core.swift
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

import AdSupport

internal protocol CoreType {
    var applicationId: String? { get set }
    var buttonDefaults: ButtonDefaultsType { get }
    var client: ClientType { get }
    var system: SystemType { get }
    var notificationCenter: NotificationCenterType { get }
    var shouldFetchPostInstallURL: Bool { get }
    var attributionToken: String? { get set }
    func clearAllData()
    func trackIncomingURL(_ url: URL)
    func handlePostInstallURL(_ completion: @escaping (URL?, Error?) -> Void)
    func trackOrder(_ order: Order, _ completion: ((Error?) -> Void)?)
    init(buttonDefaults: ButtonDefaultsType,
         client: ClientType,
         system: SystemType,
         notificationCenter: NotificationCenterType)
}

/**
 The ’core‘ instance responsible for fulfilling the public ButtonMerchant API contract.
 */
final internal class Core: CoreType {

    var applicationId: String?
    var buttonDefaults: ButtonDefaultsType
    var client: ClientType
    var system: SystemType
    var notificationCenter: NotificationCenterType

    var shouldFetchPostInstallURL: Bool {
        return !buttonDefaults.hasFetchedPostInstallURL && system.isNewInstall
    }

    var attributionToken: String? {
        get {
            return buttonDefaults.attributionToken
        }
        set {
            buttonDefaults.attributionToken = newValue
        }
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

    /**
     Clears all session data from the custom user defaults container.
     */
    func clearAllData() {
        buttonDefaults.clearAllData()
    }

    /**
     Checks and persists Button attribution in all passed URLs.

     - Parameter url: The URL to be inspected.
     */
    func trackIncomingURL(_ url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems else {
                return
        }

        if let queryItem = queryItems.first(where: {$0.name == "btn_ref"}),
            let newAttributionToken = queryItem.value {
            
            let oldAttributionToken = attributionToken
            attributionToken = newAttributionToken
            
            var isNewToken = true
            if let oldAttributionToken = oldAttributionToken {
                isNewToken = oldAttributionToken != newAttributionToken
            }
            if isNewToken {
                notificationCenter.post(name: Notification.Name.Button.AttributionTokenDidChange,
                                        object: nil,
                                        userInfo: [Notification.Key.NewToken: newAttributionToken])
            }
        }
    }

    /**
     Checks *once only* for a post-install url if installed < 12 hours ago.
     */
    func handlePostInstallURL(_ completion: @escaping (URL?, Error?) -> Void) {
        guard shouldFetchPostInstallURL else {
            completion(nil, nil)
            return
        }

        guard let appId = applicationId, !appId.isEmpty else {
            completion(nil, ConfigurationError.noApplicationId)
            return
        }

        buttonDefaults.hasFetchedPostInstallURL = true

        let postInstallBody = PostInstallBody(system: system, applicationId: appId)
        let parameters = postInstallBody.dictionaryRepresentation

        client.fetchPostInstallURL(parameters: parameters) { [weak self] url, attributionToken in
            if let token = attributionToken {
                self?.buttonDefaults.attributionToken = token
            }
            completion(url, nil)
        }
    }

    func trackOrder(_ order: Order, _ completion: ((Error?) -> Void)?) {
        guard let appId = applicationId, !appId.isEmpty else {
            if let completion = completion {
                completion(ConfigurationError.noApplicationId)
            }
            return
        }

        let trackOrderBody = TrackOrderBody(system: system,
                                            applicationId: appId,
                                            attributionToken: buttonDefaults.attributionToken,
                                            order: order)

        let parameters = trackOrderBody.dictionaryRepresentation

        client.trackOrder(parameters: parameters, completion)
    }

}
