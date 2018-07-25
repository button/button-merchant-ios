//
// AppDelegate.swift
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
import ButtonMerchant

extension String: Error {}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let yourApplicationId = { () -> String in
        guard let appId = ApplicationId.stringValue else {
            print("""
To get started and get an App ID, please see
https://developer.usebutton.com/guides/merchants/ios/button-merchant-integration-guide
""")
            return ""
        }
        return appId
    }()

    var window: UIWindow?
    var controller: ViewController? {
        guard let navigationController = window?.rootViewController as? UINavigationController,
            let controller = navigationController.viewControllers.first as? ViewController else {
                return nil
        }
        return controller
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Replace with your App ID from the Button Dashboard https://app.usebutton.com
        ButtonMerchant.configure(applicationId: yourApplicationId)

        ButtonMerchant.handlePostInstallURL { url, _ in
            if let url = url {
                NSLog("Post install: %@", url.absoluteString)
            }
        }

        controller?.navigationItem.prompt = "Application ID: \(yourApplicationId)"

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        
        ButtonMerchant.trackIncomingURL(url)
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        ButtonMerchant.trackIncomingUserActivity(userActivity)
        
        return true
    }
}
