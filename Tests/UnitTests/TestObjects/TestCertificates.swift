//
// TestCertificates.swift
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

struct TestCertificates {
    
    static let rootCAs: [SecCertificate] = {
        return (1...4).map { certNamed("AmazonRootCA\($0)") }
    }()
    
    static let rootCAPublicKeys: [SecKey] = {
        return rootCAs.compactMap { publicKeyFrom($0) }
    }()
    
    static let certChain: [SecCertificate] = {
        return ["AmazonIntermediate", "AmazonRootCA1"].map { certNamed($0) }
    }()
    
    static func certNamed(_ name: String) -> SecCertificate {
        class TestBundle {}
        let bundle = Bundle.init(for: TestBundle.self)
        let url = bundle.url(forResource: name, withExtension: "cer")
        let data = try? Data(contentsOf: url!)
        return SecCertificateCreateWithData(nil, data! as CFData)!
    }
    
    static func publicKeyNamed(_ name: String) -> SecKey {
        return publicKeyFrom(certNamed(name))
    }
    
    static func publicKeyFrom(_ cert: SecCertificate) -> SecKey {
        return SecCertificateCopyPublicKey(cert)!
    }
}
