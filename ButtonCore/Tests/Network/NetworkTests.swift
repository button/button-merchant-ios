//
// NetworkTests.swift
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
@testable import Core

struct TestRequest: RequestType {
    static var httpMethod: HTTPMethod = .post
    static var path: String = "/test"
}

extension URLResponse {
    static func stub(statusCode: Int) -> URLResponse? {
        HTTPURLResponse(url: URL(string: "#")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    }
}

class NetworkTests: XCTestCase {

    var userAgent: String!
    var urlSession: TestURLSession!
    var defaults: CoreDefaultsType!

    var network: Network!

    override func setUp() {
        userAgent = "Test (UA)"
        urlSession = TestURLSession()
        defaults = TestCoreDefaults(userDefaults: TestUserDefaults())
        network = Network(session: urlSession, userAgent: userAgent, defaults: defaults)
    }

    func testInit() {
        XCTAssertEqual(network.userAgent, "Test (UA)")
        XCTAssertEqualReferences(network.session as AnyObject, urlSession)
        XCTAssertEqualReferences(network.defaults as AnyObject, defaults)
    }

    func testFetchWhenNilAppIdPendsTask() {
        network.fetch(TestRequest()) { _, _ in }
        XCTAssertNil(urlSession.actualTask)
        XCTAssertEqual(network.pendingTasks.count, 1)
        XCTAssertTrue(network.pendingTasks.first?.request is TestRequest)
        XCTAssertNotNil(network.pendingTasks.first?.completion)
    }

    func testSetApplicationIdFlushesPendingTasks() {
        network.pendingTasks = [
            Network.PendingTask(request: TestRequest(), retryPolicy: NoRetry()),
            Network.PendingTask(request: TestRequest(), retryPolicy: NoRetry())
        ]
        network.applicationId = ApplicationId("app-abc123")
        XCTAssertEqual(urlSession.allDataTasks.count, 2)
        XCTAssertTrue(urlSession.allDataTasks[0].didResume)
        XCTAssertTrue(urlSession.allDataTasks[1].didResume)
        XCTAssertTrue(network.pendingTasks.isEmpty)
    }

    func testClearAllTasksRemovesTasks() {
        network.pendingTasks = [
            Network.PendingTask(request: TestRequest(), retryPolicy: NoRetry()),
            Network.PendingTask(request: TestRequest(), retryPolicy: NoRetry())
        ]
        network.clearAllTasks()
        XCTAssertTrue(network.pendingTasks.isEmpty)
    }

    func testFetchWhenAppIdExecutesTask() {
        network.applicationId = ApplicationId("app-abc123")
        network.fetch(TestRequest(), retryPolicy: NoRetry())
        XCTAssertEqual(urlSession.allDataTasks.count, 1)
        XCTAssertTrue(urlSession.actualTask!.didResume)
        XCTAssertEqual(
            urlSession.actualTask?.originalRequest?.url?.absoluteString,
            "https://app-abc123.mobileapi.usebutton.com/test"
        )
    }

    func testFetchWhenOK() {
        waitUntil { done in
            network.applicationId = ApplicationId("app-abc123")
            network.fetch(TestRequest(), retryPolicy: NoRetry()) { data, error in
                XCTAssertEqual(data, Data.stubData())
                XCTAssertNil(error)
                done()
            }
            urlSession.actualTask?.completion(.stubData(), .stub(statusCode: 200), nil)
        }
    }

    func testFetchWhenServerErrorCompletesWithError() {
        waitUntil { done in
            network.applicationId = ApplicationId("app-abc123")
            network.fetch(TestRequest(), retryPolicy: NoRetry()) { data, error in
                XCTAssertNil(data)
                XCTAssertEqual(error as? NetworkError, NetworkError.unknown)
                done()
            }
            urlSession.actualTask?.completion(nil, .stub(statusCode: 500), TestError.unknown)
        }
    }

    func testFetchWhenClientErrorNoRetry() {
        waitUntil { done in
            let retry = TestRetryPolicy()
            network.applicationId = ApplicationId("app-abc123")
            network.fetch(TestRequest(), retryPolicy: retry) { [self] _, error in
                XCTAssertFalse(retry.didCallNext)
                XCTAssertEqual(error as? TestError, TestError.known)
                XCTAssertEqual(urlSession.allDataTasks.count, 1)
                done()
            }
            urlSession.actualTask?.completion(nil, .stub(statusCode: 400), TestError.known)
        }
    }

    func testFetchWhenServerErrorRetries() {
        let retry = TestRetryPolicy()
        network.applicationId = ApplicationId("app-abc123")
        network.fetch(TestRequest(), retryPolicy: retry)
        urlSession.actualTask?.completion(nil, .stub(statusCode: 500), TestError.unknown)
        XCTAssertTrue(retry.didCallNext)
        XCTAssertEqual(urlSession.allDataTasks.count, 2)
        XCTAssertTrue(urlSession.allDataTasks[0].didResume)
        XCTAssertTrue(urlSession.allDataTasks[1].didResume)
    }

    func testFetchCompletesOnMain() {
        waitUntil { done in
            network.applicationId = ApplicationId("app-abc123")
            network.fetch(TestRequest(), retryPolicy: NoRetry()) { _, _ in
                XCTAssertTrue(Thread.isMainThread)
                done()
            }
            urlSession.actualTask?.completion(.stubData(), .stub(statusCode: 200), nil)
        }
    }
}
