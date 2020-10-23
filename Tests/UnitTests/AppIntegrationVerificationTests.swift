//
// AppIntegrationVerificationTests.swift
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
    
    func testHandleURL_ignoresUnknownURLs() {
        let url = URL(string: "https://example.com")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertNil(testApplication.actualURL)
    }
    
    func testCommand_unknown_doesNothing() {
        let url = URL(string: "brandapp://test.bttn.io/action/unknown")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertNil(testApplication.actualURL)
    }
    
    func testCommand_quit_quitsApp() {
        let url = URL(string: "brandapp://test.bttn.io/action/quit")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertTrue(testApplication.didQuit)
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/quit")
    }
    
    func testCommand_quit_doesNotQuitWithoutTestApp() {
        let url = URL(string: "brandapp://test.bttn.io/action/quit")!
        testApplication.stubbedOpenResult = false
        
        verifier.handleIncomingURL(url)
        
        XCTAssertFalse(testApplication.didQuit)
    }
    
    func testCommand_echo_respondsWithToken() {
        testDefaults.attributionToken = "srctok-xxxxx"
        let url = URL(string: "https://www.example.com/some/product?btn_ref=srctok-xxxxx&btn_test_echo=true")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/echo?btn_ref=srctok-xxxxx")
    }
    
    func testCommand_echo_respondsWithNullToken() {
        let url = URL(string: "https://www.example.com/some/product?btn_test_echo=true")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/echo?btn_ref=null")
    }
    
    func testCommand_getToken_respondsWithToken() {
        testDefaults.attributionToken = "srctok-xxxxx"
        let url = URL(string: "brandapp://test.bttn.io/action/get-token")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/get-token?btn_ref=srctok-xxxxx")
    }
    
    func testCommand_getToken_respondsWithNullToken() {
        let url = URL(string: "brandapp://test.bttn.io/action/get-token")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/get-token?btn_ref=null")
    }
    
    func testCommand_testPostInstall_respondsTrue() {
        testDefaults.hasFetchedPostInstallURL = true
        let url = URL(string: "brandapp://test.bttn.io/action/test-post-install")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/test-post-install?success=true")
    }
    
    func testCommand_testPostInstall_respondsFalse() {
        testDefaults.hasFetchedPostInstallURL = false
        let url = URL(string: "brandapp://test.bttn.io/action/test-post-install")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/test-post-install?success=false")
    }
    
    func testCommand_version_respondsVersion() {
        testDefaults.hasFetchedPostInstallURL = false
        let url = URL(string: "brandapp://test.bttn.io/action/version")!
        
        verifier.handleIncomingURL(url)
        
        XCTAssertEqual(testApplication.actualURL?.absoluteString, "button-brand-test://action-response/version?version=\(Version.stringValue)")
    }
}
