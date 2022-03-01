//
// AppIntegrationVerificationTests.swift
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

import XCTest
@testable import ButtonMerchant

class AppIntegrationVerificationTests: XCTestCase {

    var testApplication: TestApplication!
    var testDefaults: TestButtonDefaults!
    var verifier: AppIntegrationVerification!
    
    override func setUp() {
        super.setUp()
        testApplication = TestApplication()
        testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        verifier = AppIntegrationVerification(application: testApplication, defaults: testDefaults)
    }

    // MARK: - Commands via app scheme links

    func testAppSchemeCommand_ignoresUnnamespacedAppSchemeURLs() {
        let url = URL(string: "brandapp://example.com/action/version")!

        verifier.handleIncomingURL(url)

        XCTAssertNil(testApplication.actualURL)
    }

    func testAppSchemeCommand_unknown_doesNothing() {
        let url = URL(string: "brandapp://test.bttn.io/_bttn/action/unknown")!

        verifier.handleIncomingURL(url)

        XCTAssertNil(testApplication.actualURL)
    }
    
    func testAppSchemeCommand_quit_quitsApp() {
        let url = URL(string: "brandapp://test.bttn.io/_bttn/action/quit")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertTrue(testApplication.didQuit)
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/quit")
    }
    
    func testAppSchemeCommand_quit_doesNotQuitWithoutTestApp() {
        let url = URL(string: "brandapp://test.bttn.io/_bttn/action/quit")!
        testApplication.stubbedOpenResult = false
        
        verifier.handleIncomingURL(url)
        
        XCTAssertFalse(testApplication.didQuit)
    }
    
    func testAppSchemeCommand_echo_respondsWithToken() {
        testDefaults.attributionToken = "srctok-xxxxx"
        let url = URL(string: "https://www.example.com/some/product?btn_ref=srctok-xxxxx&btn_test_echo=true")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/echo?btn_ref=srctok-xxxxx")
    }
    
    func testAppSchemeCommand_echo_respondsWithNullToken() {
        let url = URL(string: "https://www.example.com/some/product?btn_test_echo=true")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/echo?btn_ref=null")
    }
    
    func testAppSchemeCommand_getToken_respondsWithToken() {
        testDefaults.attributionToken = "srctok-xxxxx"
        let url = URL(string: "brandapp://test.bttn.io/_bttn/action/get-token")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/get-token?btn_ref=srctok-xxxxx")
    }
    
    func testAppSchemeCommand_getToken_respondsWithNullToken() {
        let url = URL(string: "brandapp://test.bttn.io/_bttn/action/get-token")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/get-token?btn_ref=null")
    }
    
    func testAppSchemeCommand_testPostInstall_respondsTrue() {
        testDefaults.hasFetchedPostInstallURL = true
        let url = URL(string: "brandapp://test.bttn.io/_bttn/action/test-post-install")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/test-post-install?success=true")
    }
    
    func testAppSchemeCommand_testPostInstall_respondsFalse() {
        testDefaults.hasFetchedPostInstallURL = false
        let url = URL(string: "brandapp://test.bttn.io/_bttn/action/test-post-install")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/test-post-install?success=false")
    }
    
    func testAppSchemeCommand_version_respondsVersion() {
        testDefaults.hasFetchedPostInstallURL = false
        let url = URL(string: "brandapp://test.bttn.io/_bttn/action/version")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/version?version=\(Version.stringValue)")
    }

    // MARK: - Commands via universal links

    func testUniversalLinkCommand_ignoresUnnamespacedUniversaLinks() {
        let url = URL(string: "https://example.com/action/version")!

        verifier.handleIncomingURL(url)

        XCTAssertNil(testApplication.actualURL)
    }

    func testUniversalLinkCommand_unknown_doesNothing() {
        let url = URL(string: "https://example.com/_bttn/action/unknown")!

        verifier.handleIncomingURL(url)

        XCTAssertNil(testApplication.actualURL)
    }

    func testUniversalLinkCommand_quit_quitsApp() {
        let url = URL(string: "https://example.com/_bttn/action/quit")!

        verifier.handleIncomingURL(url)

        XCTAssertTrue(testApplication.didQuit)
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/quit")
    }

    func testUniversalLinkCommand_quit_doesNotQuitWithoutTestApp() {
        let url = URL(string: "https://example.com/_bttn/action/quit")!
        testApplication.stubbedOpenResult = false

        verifier.handleIncomingURL(url)

        XCTAssertFalse(testApplication.didQuit)
    }

    func testUniversalLinkCommand_echo_respondsWithToken() {
        testDefaults.attributionToken = "srctok-xxxxx"
        let url = URL(string: "https://www.example.com/some/product?btn_ref=srctok-xxxxx&btn_test_echo=true")!

        verifier.handleIncomingURL(url)

        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/echo?btn_ref=srctok-xxxxx")
    }

    func testUniversalLinkCommand_echo_respondsWithNullToken() {
        let url = URL(string: "https://www.example.com/some/product?btn_test_echo=true")!

        verifier.handleIncomingURL(url)

        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/echo?btn_ref=null")
    }

    func testUniversalLinkCommand_getToken_respondsWithToken() {
        testDefaults.attributionToken = "srctok-xxxxx"
        let url = URL(string: "https://example.com/_bttn/action/get-token")!

        verifier.handleIncomingURL(url)

        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/get-token?btn_ref=srctok-xxxxx")
    }

    func testUniversalLinkCommand_getToken_respondsWithNullToken() {
        let url = URL(string: "https://example.com/_bttn/action/get-token")!

        verifier.handleIncomingURL(url)

        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/get-token?btn_ref=null")
    }

    func testUniversalLinkCommand_testPostInstall_respondsTrue() {
        testDefaults.hasFetchedPostInstallURL = true
        let url = URL(string: "https://example.com/_bttn/action/test-post-install")!

        verifier.handleIncomingURL(url)

        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/test-post-install?success=true")
    }

    func testUniversalLinkCommand_testPostInstall_respondsFalse() {
        testDefaults.hasFetchedPostInstallURL = false
        let url = URL(string: "https://example.com/_bttn/action/test-post-install")!

        verifier.handleIncomingURL(url)

        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/test-post-install?success=false")
    }

    func testUniversalLinkCommand_version_respondsVersion() {
        testDefaults.hasFetchedPostInstallURL = false
        let url = URL(string: "https://example.com/_bttn/action/version")!

        verifier.handleIncomingURL(url)

        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/version?version=\(Version.stringValue)")
    }
}
