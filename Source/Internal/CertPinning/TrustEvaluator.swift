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
    
    var publicKeys: [SecKey] { get }
    
    func handleChallenge(_ challenge: URLAuthenticationChallengeType, completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

final internal class ImplicitTrustEvaluator: TrustEvaluatorType {
    var publicKeys: [SecKey]
    
    required init() {
        publicKeys = []
    }
    
    func handleChallenge(_ challenge: URLAuthenticationChallengeType, completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completion(.performDefaultHandling, nil)
    }
}

final internal class TrustEvaluator: TrustEvaluatorType {
    
    var publicKeys: [SecKey]
    
    required init(publicKeys: [SecKey]) {
        self.publicKeys = publicKeys
    }
    
    func handleChallenge(_ challenge: URLAuthenticationChallengeType, completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let space = challenge.getProtectionSpace()
        guard shouldPinChallenge(challenge),
            let trust = space.serverTrust else {
            completion(.performDefaultHandling, nil)
            return
        }
        
        guard validate(trust, host: space.host) else {
            completion(.cancelAuthenticationChallenge, nil)
            return
        }
        
        completion(evaluate(trust), nil)
    }
    
    private func shouldPinChallenge(_ challenge: URLAuthenticationChallengeType) -> Bool {
        let space = challenge.getProtectionSpace()
        guard space.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            space.host.contains(".usebutton.com") else {
                return false
        }
        return true
    }
    
    private func validate(_ trust: SecTrust, host: String) -> Bool {
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
    
    private func evaluate(_ trust: SecTrust) -> URLSession.AuthChallengeDisposition {
        let count = SecTrustGetCertificateCount(trust)
        let serverCerts = [Int](0..<count).compactMap { SecTrustGetCertificateAtIndex(trust, $0) }
        var serverKeys = [SecKey]()
        if #available(iOS 10.3, *) {
            serverKeys = serverCerts.compactMap { SecCertificateCopyPublicKey($0) }
        }
        
        for serverKey in serverKeys.reversed() {
            for key in publicKeys where key == serverKey {
                return .performDefaultHandling
            }
        }
        return .cancelAuthenticationChallenge
    }
}
