//
// ButtonMerchant.swift
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

import UIKit
import AdSupport

/**
 `ButtonMerchant` is the main entry point to the library.

 To get started with your integration,
 get your application Id from from the [Button Dashboard](https://app.usebutton.com).
 and follow our simple [integration guide](https://developer.usebutton.com/guides/merchants/ios/open-source-merchant-library)
 */
final public class ButtonMerchant: NSObject {
    
    // swiftlint:disable:next identifier_name
    internal static var _core: CoreType?
    private static var core: CoreType {
        get {
            let core = _core ?? createCore()
            _core = core
            return core
        }
        // This should never be set directly
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
    @objc public static var attributionToken: String? {
        return core.attributionToken
    }

    /**
     Configures ButtonMerchant with your application Id.

     - Note:
     Get your application Id from from the [Button Dashboard](https://app.usebutton.com)

     - Parameters:
        - applicationId: Your application Id (required)

     */
    @objc public static func configure(applicationId: String) {
        core.applicationId = applicationId
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
    @objc public static func trackIncomingURL(_ url: URL) {
        core.trackIncomingURL(url)
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
    @objc public static func trackIncomingUserActivity(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else {
            return
        }
        core.trackIncomingURL(url)
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
    @objc public static func handlePostInstallURL(_ completion: @escaping (URL?, Error?) -> Void) {
        core.handlePostInstallURL(completion)
    }

    /**
     Tracks an order.

     This signal is used to power the Instant Rewards feature for Publishers to notify
     their customers as quickly as possible that their order has been correctly tracked.

     - Attention:
     This does not replace server-side order reporting to Button.
     [See: order reporting](https://developer.usebutton.com/guides/merchants/ios/report-orders-to-button#report-orders-to-buttons-order-api)
     */
    @objc public static func trackOrder(_ order: Order, completion: ((Error?) -> Void)? = nil) {
        core.trackOrder(order, completion)
    }

    /**
     Discards the current session and all persisted data.
     */
    @objc public static func clearAllData() {
        core.clearAllData()
    }
    
    // MARK: Private
    
    private static func createCore() -> CoreType {
        let system = System(fileManager: FileManager.default,
                            calendar: Calendar.current,
                            adIdManager: ASIdentifierManager.shared(),
                            device: UIDevice.current,
                            screen: UIScreen.main,
                            locale: NSLocale.current,
                            bundle: Bundle.main)
        return Core(buttonDefaults: ButtonDefaults(userDefaults: UserDefaults.button),
                    client: Client(session: URLSession.shared, userAgent: UserAgent(libraryVersion: Version.stringValue, system: system)),
                    system: system,
                    notificationCenter: NotificationCenter.default)
    }
}
