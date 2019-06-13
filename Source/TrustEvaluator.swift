//
// TrustEvaluator.swift
//
// Copyright © 2019 Button, Inc. All rights reserved. (https://usebutton.com)
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

internal protocol TrustEvaluatorType: class {
    var pinnables: [Pinnable] { get set }
    var strategy: ValidationStrategy { get set }
    
    func shouldPinChallenge(_ challenge: URLAuthenticationChallenge) -> Bool
    func validate(_ trust: SecTrust, host: String) -> Bool
    
    func evaluate(_ trust: SecTrust) -> URLSession.AuthChallengeDisposition
}

final internal class TrustEvaluator: TrustEvaluatorType {
    var pinnables: [Pinnable]
    var strategy: ValidationStrategy
    
    required init(certificates: [SecCertificate], strategy: ValidationStrategy) {
        self.strategy = strategy
        pinnables = strategy.pinnables(from: certificates)
    }
    
    func shouldPinChallenge(_ challenge: URLAuthenticationChallenge) -> Bool {
        let space = challenge.protectionSpace
        guard pinnables.count > 0,
            space.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            space.host.contains(".usebutton.com") else {
                return false
        }
        return true
    }
    
    func validate(_ trust: SecTrust, host: String) -> Bool {
        let policy = SecPolicyCreateSSL(true, host as CFString)
        SecTrustSetPolicies(trust, policy)
        
        var result = SecTrustResultType.invalid
        let status = SecTrustEvaluate(trust, &result)
        guard status == errSecSuccess,
            result == .proceed || result == .unspecified else {
                return false
        }
        return true
    }
    
    func evaluate(_ trust: SecTrust) -> URLSession.AuthChallengeDisposition {
        let count = SecTrustGetCertificateCount(trust)
        let trustCertificates = [Int](0..<count).compactMap { SecTrustGetCertificateAtIndex(trust, $0) }
        let serverPinnables = strategy.pinnables(from: trustCertificates)
        
        for serverPinnable in serverPinnables.reversed() {
            for pinnable in pinnables {
                if pinnable.isEqualTo(serverPinnable) {
                    return .performDefaultHandling
                }
            }
        }
        
        return .cancelAuthenticationChallenge
    }
}
