/**

 AppDelegate.swift

 Copyright © 2018 Button, Inc. All rights reserved. (https://usebutton.com)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

*/

import UIKit
import ButtonMerchant

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let applicationId = "app-abc123"

    var window: UIWindow?
    var controller: ViewController? {
        guard let navigationController = window?.rootViewController as? UINavigationController,
            let controller = navigationController.viewControllers.first as? ViewController else {
                return nil
        }
        return controller
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        ButtonMerchant.configure(applicationId: applicationId)
        
        controller?.navigationItem.prompt = "Application ID: \(applicationId)"

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        
        ButtonMerchant.trackIncomingURL(url)
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        if let url = userActivity.webpageURL {
            ButtonMerchant.trackIncomingURL(url)
        }
        
        return true
    }
}
