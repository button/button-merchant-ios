//
// IntegrationTests.swift
//
// Copyright © 2018 Button. All rights reserved. (https://usebutton.com)
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

class IntegrationTests: XCTestCase {
    
    private let testSuiteName = "com.usebutton.merchant.tests"
    
    override func setUp() {
        super.setUp()
        UserDefaults.Button.suiteName = testSuiteName
        ButtonMerchant.clearAllData()
    }
    
    func testUnattributedURLDoesNotStoreToken() {
        ButtonMerchant.trackIncomingURL(URL(string: "http://usebutton.com")!)

        XCTAssertNil(ButtonMerchant.attributionToken)
    }
    
    func testAttributedURLStoresToken() {
        let expectedAttributionToken = "srctok-123"
        let url = URL(string: "http://usebutton.com/foo?btn_ref=\(expectedAttributionToken)")!
        
        ButtonMerchant.trackIncomingURL(url)
        
        XCTAssertEqual(ButtonMerchant.attributionToken, expectedAttributionToken)
    }
    
    func testAttributedURLOverwritesToken() {
        let expectedAttributionToken = "srctok-abc"
        let url1 = URL(string: "http://usebutton.com/foo?btn_ref=srctok-123")!
        let url2 = URL(string: "http://usebutton.com/foo?btn_ref=\(expectedAttributionToken)")!
        
        ButtonMerchant.trackIncomingURL(url1)
        ButtonMerchant.trackIncomingURL(url2)
        
        XCTAssertEqual(ButtonMerchant.attributionToken, expectedAttributionToken)
    }
    
    func testAttributedURLPostsNotification() {
        let expectation = XCTestExpectation(description: "token update notification")
        let expectedAttributionToken = "srctok-123"
        let expectedUserInfo = [Notification.Key.NewToken: expectedAttributionToken] as NSDictionary
        let url = URL(string: "http://usebutton.com/foo?btn_ref=\(expectedAttributionToken)")!
        
        let center = NotificationCenter.default
        var observer: Any?
        let observation: (Notification) -> Void = { notification in
            XCTAssertEqual(ButtonMerchant.attributionToken, expectedAttributionToken)
            XCTAssertNotNil(notification.userInfo)
            XCTAssertEqual(expectedUserInfo, notification.userInfo! as NSDictionary)
            if let observer = observer {
                center.removeObserver(observer)
            }
            expectation.fulfill()
        }
        observer = center.addObserver(forName: Notification.Name.Button.AttributionTokenDidChange,
                                      object: nil,
                                      queue: nil,
                                      using: observation)
        
        ButtonMerchant.trackIncomingURL(url)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testAttributedURLPostsMultipleNotifications() {
        let expectation = XCTestExpectation(description: "token update notification")
        
        let firstExpectedAttributionToken = "srctok-123"
        let firstExpectedUserInfo = [Notification.Key.NewToken: firstExpectedAttributionToken] as NSDictionary
        let firstURL = URL(string: "http://usebutton.com/foo?btn_ref=\(firstExpectedAttributionToken)")!
        let secondExpectedAttributionToken = "srctok-321"
        let secondExpectedUserInfo = [Notification.Key.NewToken: secondExpectedAttributionToken] as NSDictionary
        let secondURL = URL(string: "http://usebutton.com/foo?btn_ref=\(secondExpectedAttributionToken)")!
        
        let center = NotificationCenter.default
        
        var firstObserver: Any?
        let firstObservation: (Notification) -> Void = { notification in
            XCTAssertEqual(ButtonMerchant.attributionToken, firstExpectedAttributionToken)
            XCTAssertNotNil(notification.userInfo)
            XCTAssertEqual(firstExpectedUserInfo, notification.userInfo! as NSDictionary)
        }
        firstObserver = center.addObserver(forName: Notification.Name.Button.AttributionTokenDidChange,
                                           object: nil,
                                           queue: nil,
                                           using: firstObservation)
        ButtonMerchant.trackIncomingURL(firstURL)
        if let observer = firstObserver {
            center.removeObserver(observer)
        }
        
        var secondObserver: Any?
        let secondObservation: (Notification) -> Void = { notification in
            XCTAssertEqual(ButtonMerchant.attributionToken, secondExpectedAttributionToken)
            XCTAssertNotNil(notification.userInfo)
            XCTAssertEqual(secondExpectedUserInfo, notification.userInfo! as NSDictionary)
            if let observer = secondObserver {
                center.removeObserver(observer)
            }
            expectation.fulfill()
        }
        secondObserver = center.addObserver(forName: Notification.Name.Button.AttributionTokenDidChange,
                                            object: nil,
                                            queue: nil,
                                            using: secondObservation)
        ButtonMerchant.trackIncomingURL(secondURL)
        
        self.wait(for: [expectation], timeout: 2.0)
    }
    
    func testClearDataRemovesUserDefaults() {
        let expectedAttributionToken = "srctok-abc"
        let url1 = URL(string: "http://usebutton.com/foo?btn_ref=\(expectedAttributionToken)")!
        
        ButtonMerchant.trackIncomingURL(url1)
        ButtonMerchant.clearAllData()
        
        XCTAssertNil(ButtonMerchant.attributionToken)
    }
}
