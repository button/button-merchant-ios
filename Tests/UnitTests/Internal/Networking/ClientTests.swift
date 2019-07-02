//
// ClientTests.swift
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

//swiftlint:disable file_length

import XCTest
@testable import ButtonMerchant

class ClientTests: XCTestCase {

    func testInitialization() {
        // Arrange
        let expectedNetwork = TestNetwork()
        let expectedResponesHandler = TestNetworkResponseHandler()

        // Act
        let client = Client(network: expectedNetwork, responseHandler: expectedResponesHandler)

        // Assert
        XCTAssertEqualReferences(client.network, expectedNetwork)
        XCTAssertEqualReferences(client.responseHandler as AnyObject, expectedResponesHandler)
    }

    func testFetchPostInstall_invokesNetwork() {
        // Arrange
        let expectedEndpoint: API = .postInstall(parameters: [:])
        let expectedCompletion: (URL?, String?) -> Void = { _, _ in }
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)

        // Act
        client.fetchPostInstallURL(parameters: [:], expectedCompletion)

        // Assert
        XCTAssertEqual(network.actualEndpoint, expectedEndpoint)
        XCTAssertNotNil(network.actualCompletion)
    }

    func testFetchPostInstall_nilResponse_completesWithNilValues() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install failure")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)

        // Act
        client.fetchPostInstallURL(parameters: [:]) { url, token in
            // Assert
            XCTAssertNil(url)
            XCTAssertNil(token)
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(Data(), nil, TestError.unknown)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testFetchPostInstall_successfulResponse_nilData_completesWithNilValues() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install failure")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Act
        client.fetchPostInstallURL(parameters: [:]) { url, token in
            // Assert
            XCTAssertNil(url)
            XCTAssertNil(token)
            XCTAssertEqual(responseHandler.actualResponse, response)
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(nil, response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testFetchPostInstall_successfulResponse_badPayload_completesWithNilValues() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install failure")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseArray = ["foo": ["bar": "baz"]]
        let data = try? JSONSerialization.data(withJSONObject: responseArray)

        // Act
        client.fetchPostInstallURL(parameters: [:]) { url, token in
            // Assert
            XCTAssertNil(url)
            XCTAssertNil(token)
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(data, response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testFetchPostInstall_successfulResponse_missingObject_completesWithNilValues() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install failure")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseDict: [String: Any] = ["foo": "bar"]
        let data = try? JSONSerialization.data(withJSONObject: responseDict)

        // Act
        client.fetchPostInstallURL(parameters: [:]) { url, token in
            // Assert
            XCTAssertNil(url)
            XCTAssertNil(token)
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(data, response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testFetchPostInstall_successfulResponse_missingAction_completesWithNilValues() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install failure")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseDict: [String: Any] = ["object": ["foo": "bar"]]
        let data = try? JSONSerialization.data(withJSONObject: responseDict)

        // Act
        client.fetchPostInstallURL(parameters: [:]) { url, token in
            // Assert
            XCTAssertNil(url)
            XCTAssertNil(token)
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(data, response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testFetchPostInstall_successfulResponse_missingAttribution_completesWithNilValues() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install failure")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseDict: [String: Any] = ["object": ["action": "https://usebutton.com"]]
        let data = try? JSONSerialization.data(withJSONObject: responseDict)

        // Act
        client.fetchPostInstallURL(parameters: [:]) { url, token in
            // Assert
            XCTAssertNil(url)
            XCTAssertNil(token)
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(data, response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testFetchPostInstall_successfulResponse_missingSourceToken_completesWithNilValues() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install failure")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseDict: [String: Any] = ["object": ["action": "https://usebutton.com",
                                                      "attribution": ["foo": "src-tok"]]]
        let data = try? JSONSerialization.data(withJSONObject: responseDict)

        // Act
        client.fetchPostInstallURL(parameters: [:]) { url, token in
            // Assert
            XCTAssertNil(url)
            XCTAssertNil(token)
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(data, response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testFetchPostInstall_success_completesWith_url_token() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install success")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let expectedURL = URL(string: "https://usebutton.com")!
        let expectedToken = "src-tok"
        let response = HTTPURLResponse(url: expectedURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        let responseDict: [String: Any] = ["object": ["action": expectedURL.absoluteString,
                                                      "attribution": ["btn_ref": expectedToken]]]
        let data = try? JSONSerialization.data(withJSONObject: responseDict)

        // Act
        client.fetchPostInstallURL(parameters: [:]) { url, token in
            // Assert
            XCTAssertEqual(url, expectedURL)
            XCTAssertEqual(token, expectedToken)
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(data, response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testFetchPostInstall_failure_completesWithNilValues() {
        // Arrange
        let expectation = XCTestExpectation(description: "fetch post install failure")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler(result: .failure(TestError.known))
        let client = Client(network: network, responseHandler: responseHandler)
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)

        // Act
        client.fetchPostInstallURL(parameters: [:]) { url, token in
            // Assert
            XCTAssertNil(url)
            XCTAssertNil(token)
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(nil, response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testTrackOrder_invokesNetwork() {
        // Arrange
        let expectedEndpoint: API = .activity(parameters: [:])
        let expectedCompletion: (Error?) -> Void = { _ in }
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)

        // Act
        client.trackOrder(parameters: [:], expectedCompletion)

        // Assert
        XCTAssertEqual(network.actualEndpoint, expectedEndpoint)
        XCTAssertNotNil(network.actualCompletion)
    }

    func testTrackOrder_nilResponse_completesWithClientError() {
        // Arrange
        let expectation = XCTestExpectation(description: "track order completion")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let expectedError = ClientError.emptyResponse

        // Act
        client.trackOrder(parameters: [:]) { error in
            // Assert
            //swiftlint:disable:next force_cast
            let clientError = error as! ClientError
            XCTAssert(clientError.isEqual(to: expectedError))
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(Data(), nil, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testTrackOrder_errors_completesWithError() {
        // Arrange
        let expectation = XCTestExpectation(description: "track order completion")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let expectedError = TestError.known
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Act
        client.trackOrder(parameters: [:]) { error in
            // Assert
            //swiftlint:disable:next force_cast
            let testError = error as! TestError
            XCTAssert(testError.isEqual(to: expectedError))
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(Data(), response, TestError.known)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testTrackOrder_success_completesWithNilError() {
        // Arrange
        let expectation = XCTestExpectation(description: "track order success")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Act
        client.trackOrder(parameters: [:]) { error in
            // Assert
            XCTAssertNil(error)
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(Data(), response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testTrackOrder_failure_completesWithError() {
        // Arrange
        let expectation = XCTestExpectation(description: "track order failure")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler(result: .failure(TestError.known))
        let client = Client(network: network, responseHandler: responseHandler)
        let expectedError = TestError.known
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Act
        client.trackOrder(parameters: [:]) { error in
            // Assert
            //swiftlint:disable:next force_cast
            let testError = error as! TestError
            XCTAssert(testError.isEqual(to: expectedError))
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(Data(), response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testReportOrder_invokesNetwork() {
        // Arrange
        let expectedEndpoint: API = .order(parameters: [:], encodedAppId: "app-id")
        let expectedCompletion: (Error?) -> Void = { _ in }
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)

        // Act
        client.reportOrder(parameters: [:], encodedApplicationId: "app-id", expectedCompletion)

        // Assert
        XCTAssertEqual(network.actualEndpoint, expectedEndpoint)
        XCTAssertNotNil(network.actualCompletion)
    }

    func testReportOrder_nilResponse_completesWithClientError() {
        // Arrange
        let expectation = XCTestExpectation(description: "report order completion")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let expectedError = ClientError.emptyResponse

        // Act
        client.reportOrder(parameters: [:], encodedApplicationId: "appId") { error in
            // Assert
            //swiftlint:disable:next force_cast
            let clientError = error as! ClientError
            XCTAssert(clientError.isEqual(to: expectedError))
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(Data(), nil, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testReportOrder_errors_completesWithError() {
        // Arrange
        let expectation = XCTestExpectation(description: "report order completion")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let expectedError = TestError.known
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Act
        client.reportOrder(parameters: [:], encodedApplicationId: "appId") { error in
            // Assert
            //swiftlint:disable:next force_cast
            let testError = error as! TestError
            XCTAssert(testError.isEqual(to: expectedError))
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(Data(), response, TestError.known)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testReportOrder_success_completesWithNilError() {
        // Arrange
        let expectation = XCTestExpectation(description: "report order success")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler()
        let client = Client(network: network, responseHandler: responseHandler)
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Act
        client.reportOrder(parameters: [:], encodedApplicationId: "appId") { error in
            // Assert
            XCTAssertNil(error)
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(Data(), response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testReportOrder_failure_completesWithError() {
        // Arrange
        let expectation = XCTestExpectation(description: "report order failure")
        let network = TestNetwork()
        let responseHandler = TestNetworkResponseHandler(result: .failure(TestError.known))
        let client = Client(network: network, responseHandler: responseHandler)
        let expectedError = TestError.known
        let response = HTTPURLResponse(url: URL(string: "https://usebutton.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        // Act
        client.reportOrder(parameters: [:], encodedApplicationId: "appId") { error in
            // Assert
            //swiftlint:disable:next force_cast
            let testError = error as! TestError
            XCTAssert(testError.isEqual(to: expectedError))
            expectation.fulfill()
        }

        if let completion = network.actualCompletion {
            completion(Data(), response, nil)
        } else {
            XCTFail("completion was not set")
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

}
