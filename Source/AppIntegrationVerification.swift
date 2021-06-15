//
// AppIntegrationVerification.swift
//
// Copyright © 2020 Button, Inc. All rights reserved. (https://usebutton.com)
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

internal protocol AppIntegrationVerificationType: AnyObject {
    var application: UIApplicationType { get }
    var buttonDefaults: ButtonDefaultsType { get }
    func handleIncomingURL(_ url: URL)
    init(application: UIApplicationType, defaults: ButtonDefaultsType)
}

internal class AppIntegrationVerification: AppIntegrationVerificationType {
    
    enum Command: String {
        
        case quit
        case echo = "btn_test_echo"
        case getToken = "get-token"
        case testPostInstall = "test-post-install"
        case version
        
        enum Response {
            
            private static let baseURLString = "button-brand-test://action-response/"
            
            // swiftlint:disable identifier_name
            case quit
            case echo(token: String)
            case getToken(token: String)
            case testpostInstall(success: Bool)
            case version(version: String)
            // swiftlint:enable identifier_name
            
            var url: URL {
                switch self {
                case .quit:
                    return URL(string: Self.baseURLString.appending("quit"))!
                case .echo(let token):
                    return URL(string: Self.baseURLString.appending("echo?btn_ref=\(token)"))!
                case .getToken(let token):
                    return URL(string: Self.baseURLString.appending("get-token?btn_ref=\(token)"))!
                case .testpostInstall(let success):
                    return URL(string: Self.baseURLString.appending("test-post-install?success=\(success)"))!
                case .version(let version):
                    return URL(string: Self.baseURLString.appending("version?version=\(version)"))!
                }
            }
        }
        
        init?(url: URL) {
            guard let rawValue = Self.commandFrom(url: url) else {
                return nil
            }
            self.init(rawValue: rawValue)
        }
    }
    
    var application: UIApplicationType
    var buttonDefaults: ButtonDefaultsType
    var token: String {
        buttonDefaults.attributionToken ?? "null"
    }
    
    required init(application: UIApplicationType, defaults: ButtonDefaultsType) {
        self.application = application
        self.buttonDefaults = defaults
    }
    
    func handleIncomingURL(_ url: URL) {
        guard let command = Command(url: url) else {
            return
        }
        
        switch command {
        case .echo:
            reportResult(url: Command.Response.echo(token: token).url)
        case .getToken:
            reportResult(url: Command.Response.getToken(token: token).url)
        case .testPostInstall:
            reportResult(url: Command.Response.testpostInstall(success: buttonDefaults.hasFetchedPostInstallURL).url)
        case .version:
            reportResult(url: Command.Response.version(version: Version.stringValue).url)
        case .quit:
            reportResult(url: Command.Response.quit.url) { success in
                if success {
                    self.application.quit()
                }
            }
        }
    }
    
    func reportResult(url: URL, completion: ((Bool) -> Void)? = nil) {
        if #available(iOS 10.0, *) {
            application.open(url, options: [:], completionHandler: completion)
        }
    }
}

extension AppIntegrationVerification.Command {
    
    static func commandFrom(url: URL) -> String? {
        if isEchoCommand(url: url) {
            return Self.echo.rawValue
        }

        // Must be: *://*/_bttn/action/*
        let components = url.pathComponents
        if components.count == 4,
           components[1] == "_bttn",
           components[2] == "action" {
            return components.last
        }
        
        return nil
    }
    
    static func isEchoCommand(url: URL) -> Bool {
        guard let urlComponents = URLComponents(string: url.absoluteString),
              let echoItem = urlComponents.queryItems?.first(where: { $0.name == Self.echo.rawValue }),
              ((echoItem.value as NSString?)?.boolValue ?? false) else {
            return false
        }
        return true
    }
}
