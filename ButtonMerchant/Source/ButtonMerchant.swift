//
// ButtonMerchant.swift
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

import UIKit
import AdSupport

/**
 `ButtonMerchant` is the main entry point to the library.

 To get started with your integration,
 get your application Id from from the [Button Dashboard](https://app.usebutton.com).
 and follow our simple [integration guide](https://developer.usebutton.com/docs/ios-add-merchant-library)
 */
@objcMembers
final public class ButtonMerchant: NSObject {
    
    // swiftlint:disable:next identifier_name
    internal static var _instance: ButtonMerchantInternal?
    private static var instance: ButtonMerchantInternal {
        get {
            let instance = _instance ?? createInstance()
            _instance = instance
            return instance
        }
        // This should never be set directly
        // swiftlint:disable:next unused_setter_value
        set { }
    }
    
    /**
     The last tracked `attributionToken` from an inbound Button attributed URL.

     - Attention:
     For attribution to work correctly, you must:
     - Always access this token directly—**never cache it**.
     - Never manage the lifecycle of this token—Button manages the token validity window server-side.
     - Always include this value when reporting orders to your order API

    */
    public static var attributionToken: String? {
        return instance.attributionToken
    }

    /**
     Configures ButtonMerchant with your application Id.

     - Note:
     Get your application Id from from the [Button Dashboard](https://app.usebutton.com)

     - Parameters:
        - applicationId: Your application Id (required)

     */
    public static func configure(applicationId: String) {
        let appId = ApplicationId(applicationId)
        if appId == nil {
            let error = ConfigurationError.invalidApplicationId(appicationId: applicationId)
            print("Button :: \(error.localizedDescription)")
        }
        instance.applicationId = appId
    }
    
    /**
     Checks the passed URL for a Button attribution and if present stores the token.

     - Attention:
     To correctly attribute customers, you must call this method with every
     incoming `url` and `userActivity` from the following `UIApplicationDelegate` methods:

     - `application(_:open:options:)`
     - `application(_:userActivity:restorationHandler:)`

     - Parameters:
        - url: A URL that has entered your app from a third party source.

     */
    public static func trackIncomingURL(_ url: URL) {
        instance.trackIncomingURL(url)
    }
    
    /**
     Checks the URL in the passed NSUserActivity for a Button attribution and if present stores the token.
     
     - Attention:
     To correctly attribute customers, you must call this method with every
     incoming `userActivity` from the following `UIApplicationDelegate` method:
     
     - `application(_:userActivity:restorationHandler:)`
     
     - Parameters:
     - userActivity: A NSUserActivity with which your app has been continued.
     
     */
    public static func trackIncomingUserActivity(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else {
            return
        }
        instance.trackIncomingURL(url)
    }
    
    /**
     Checks to see if the user visited a url prior to installing your app.

     If a url is found, your completion handler will be called with the url and you are responsible
     for navigating the user to the relevant content in your app. If a url is not found or an error occurs, your
     completion handler will be called without a url and you can continue with your normal launch sequence.

     - Attention:
     This method checks for a post-install url exactly *one time* after a user has installed your app.
     Subsequent calls will result in your completion handler being called without a url. You do not need to wait
     for the completion handler before continuing with your normal launch sequence but you should be prepared
     to handle a post-install url is one is found. All subsequent incoming urls will be routed to your
     `UIApplicationDelegate` as usual.

     - Parameters:
        - completion: A completion block taking an optional url and optional error.
     */
    public static func handlePostInstallURL(_ completion: @escaping (URL?, Error?) -> Void) {
        instance.handlePostInstallURL(completion)
    }

    /**
     Reports an order to Button.

     - Parameters:
       - order: Your order object to be reported.
       - completion: An optional completion block taking an optional error.

     See also: Reporting Orders to Button
     ([docs](https://developer.usebutton.com/guides/merchants/ios/report-orders-to-button#report-orders-to-buttons-order-api))
    */
    public static func reportOrder(_ order: Order, completion: ((Error?) -> Void)? = nil) {
        instance.reportOrder(order, completion)
    }

    /**
     Discards the current session and all persisted data.
     */
    public static func clearAllData() {
        instance.clearAllData()
    }

    /**
     An interface through which library features can be enabled/disabled.
     */
    public static var features: Configurable {
        return instance.system
    }
    
    /**
     An interface through which user activity can be reported.
     */
    public static var activity: Activity {
        return instance.client
    }

    // MARK: Private
    
    private static func createInstance() -> ButtonMerchantInternal {
        let system = System(fileManager: FileManager.default,
                            calendar: Calendar.current,
                            adIdManager: ASIdentifierManager.shared(),
                            device: UIDevice.current,
                            screen: UIScreen.main,
                            locale: NSLocale.current,
                            bundle: Bundle.main)
        let session = URLSession(configuration: .default,
                                 delegate: SessionDelegate(systemVersion: system.device.systemVersion),
                                 delegateQueue: nil)
        let defaults = Defaults(userDefaults: UserDefaults.button)
        let client = Client(defaults: defaults,
                            system: system,
                            network: Network(session: session,
                                             userAgent: UserAgent(libraryVersion: Version.stringValue, system: system).stringRepresentation,
                                             defaults: defaults))
        let verifier = AppIntegrationVerification(application: UIApplication.shared, defaults: defaults)
        return Internal(defaults: defaults,
                    client: client,
                    system: system,
                    notificationCenter: NotificationCenter.default,
                    verifier: verifier)
    }
}

// MARK: - Deprecations

extension ButtonMerchant {
    /**
     Deprecated.

     This method is deprecated and will be removed in a future version. It is safe to remove your usage of this method.
     */
    @available(*, deprecated, message: "No longer supported. You can safely remove your usage of this method.")
    @objc public static func trackOrder(_ order: Order, completion: ((Error?) -> Void)? = nil) {
        guard let completion = completion else {
            return
        }
        completion(ButtonMerchantError.trackOrderDeprecationError)
    }
}
