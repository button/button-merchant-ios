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
    var applicationId: ApplicationId? { get set }
    var buttonDefaults: ButtonDefaultsType { get }
    var client: ClientType { get }
    var system: SystemType { get }
    var notificationCenter: NotificationCenterType { get }
    var shouldFetchPostInstallURL: Bool { get }
    var attributionToken: String? { get set }
    func clearAllData()
    func trackIncomingURL(_ url: URL)
    func handlePostInstallURL(_ completion: @escaping (URL?, Error?) -> Void)
    func reportOrder(_ order: Order, _ completion: ((Error?) -> Void)?)
    init(buttonDefaults: ButtonDefaultsType,
         client: ClientType,
         system: SystemType,
         notificationCenter: NotificationCenterType)
}

/**
 The ’core‘ instance responsible for fulfilling the public ButtonMerchant API contract.
 */
final internal class Core: CoreType {

    var applicationId: ApplicationId? {
        didSet {
            client.applicationId = applicationId
        }
    }
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
        self.applicationId = nil
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
        client.pendingTasks.removeAll()
    }

    /**
     Checks and persists Button attribution in all passed URLs.
     
     - Parameter url: The URL to be inspected.
     */
    func trackIncomingURL(_ url: URL) {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        
        let queryItems = urlComponents.queryItems
        urlComponents.queryItems = nil
        urlComponents.fragment = nil
        
        var incomingToken: String?
        if let queryItems = queryItems {
            var allowedQueryItems = [URLQueryItem]()
            queryItems.forEach { item in
                switch item.name.lowercased() {
                case "btn_ref":
                    incomingToken = item.value
                    updateAttributionIfNeeded(token: incomingToken)
                    allowedQueryItems.append(item)
                case "from_landing",
                     "from_tracking",
                     _ where item.name.lowercased().hasPrefix("btn_"):
                    allowedQueryItems.append(item)
                default:
                    break
                }
            }
            urlComponents.queryItems = allowedQueryItems
        }
        
        guard let filteredURL = urlComponents.url else {
            return
        }
        
        let event = AppEvent(name: "btn:deeplink-opened",
                             value: [ "url": filteredURL.absoluteString],
                             attributionToken: incomingToken,
                             time: system.currentDate.eventISO8601String,
                             uuid: UUID().uuidString)
        client.reportEvents([event], ifa: system.advertisingId, nil)
    }
    
    private func updateAttributionIfNeeded(token: String?) {
        guard let incomingToken = token else {
            return
        }
        
        let oldAttributionToken = attributionToken
        attributionToken = incomingToken
        
        var isNewToken = true
        if let oldAttributionToken = oldAttributionToken {
            isNewToken = oldAttributionToken != incomingToken
        }
        if isNewToken {
            notificationCenter.post(name: Notification.Name.Button.AttributionTokenDidChange,
                                    object: nil,
                                    userInfo: [Notification.Key.NewToken: incomingToken])
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

        guard applicationId != nil else {
            completion(nil, ConfigurationError.noApplicationId)
            return
        }

        buttonDefaults.hasFetchedPostInstallURL = true

        let postInstallBody = PostInstallBody(system: system)
        let parameters = postInstallBody.dictionaryRepresentation
        
        client.fetchPostInstallURL(parameters: parameters) { [weak self] url, attributionToken in
            guard self?.buttonDefaults.attributionToken == nil,
                let token = attributionToken else {
                    completion(nil, nil)
                    return
            }
            self?.buttonDefaults.attributionToken = token
            completion(url, nil)
        }
    }
    
    func reportOrder(_ order: Order, _ completion: ((Error?) -> Void)?) {
        guard applicationId != nil else {
            if let completion = completion {
                completion(ConfigurationError.noApplicationId)
            }
            return
        }
        
        let reportOrderBody = ReportOrderBody(system: system, attributionToken: buttonDefaults.attributionToken, order: order)
        let request = ReportOrderRequest(parameters: reportOrderBody.dictionaryRepresentation)
        client.reportOrder(orderRequest: request, completion)
    }

}
