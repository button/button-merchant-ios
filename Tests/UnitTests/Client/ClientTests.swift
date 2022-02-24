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

import XCTest
@testable import ButtonMerchant
@testable import Core

class ClientTests: XCTestCase {

    var testSystem: TestSystem!
    var testDefaults: TestButtonDefaults!
    var testNetwork: TestNetwork!
    var client: ClientType!

    override func setUp() {
        testSystem = TestSystem()
        testDefaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        testNetwork = TestNetwork()
        client = Client(defaults: testDefaults,
                        system: testSystem,
                        network: testNetwork)
    }

    func testInit() {
        // Arrange
        let defaults = TestButtonDefaults(userDefaults: TestUserDefaults())
        let network = TestNetwork()

        // Act
        let client = Client(defaults: defaults,
                            system: TestSystem(),
                            network: network)

        // Assert
        XCTAssertNil(client.applicationId)
        XCTAssertEqualReferences(client.defaults as AnyObject, defaults)
        XCTAssertEqualReferences(client.network as AnyObject, network)
    }

    func testSetApplicationIdSetsNetworkApplicationId() {
        XCTAssertNil(testNetwork.applicationId)
        client.applicationId = ApplicationId("app-test")
        XCTAssertEqual(testNetwork.applicationId?.rawValue, "app-test")
    }

    func testFetchPostInstallURLCompletesWithMatch() {
        waitUntil { done in
            let data = [
                "meta": [
                    "status": "ok",
                ],
                "object": [
                    "action": "https://example.com?btn_ref=srctok-test",
                    "attribution": [
                        "btn_ref": "srctok-test"
                    ]
                ]
            ].toData()

            client.fetchPostInstallURL { url, token in
                XCTAssertEqual(url?.absoluteString, "https://example.com?btn_ref=srctok-test")
                XCTAssertEqual(token, "srctok-test")
                done()
            }
            XCTAssertTrue(testNetwork.actualRequest is PostInstallRequest)
            XCTAssertEqual(PostInstallRequest.httpMethod, .post)
            XCTAssertEqual(PostInstallRequest.path, "/v1/app/deferred-deeplink")
            testNetwork.actualCompletion?(data, nil)
        }
    }

    func testFetchPostInstallURLCompletesNoMatch() {
        waitUntil { done in
            let data = [
                "meta": [
                    "status": "ok",
                ]
            ].toData()

            client.fetchPostInstallURL { url, token in
                XCTAssertNil(url)
                XCTAssertNil(token)
                done()
            }
            XCTAssertTrue(testNetwork.actualRequest is PostInstallRequest)
            testNetwork.actualCompletion?(data, nil)
        }
    }

    func testReportOrderCreatesOrderRequest() {
        // Arrange
        testDefaults.testToken = "srctok-test"
        let item = Order.LineItem(id: "item-test", total: 1000)
        item.quantity = 1
        item.itemDescription = "1000 pennies"
        item.sku = "sku-test"
        item.upc = "upc-test"
        item.category = ["test"]
        item.attributes = ["foo": "bar"]
        let order = Order(
            id: "order-test",
            purchaseDate: Date.ISO8601Formatter.date(from: "2022-02-01T00:00:00Z")!,
            lineItems: [item]
        )
        order.customerOrderId = "cust-order-id-test"
        order.customer = Order.Customer(id: "cust-test")
        order.customer?.email = "test@example.com"
        order.customer?.isNew = true

        // Act
        client.reportOrder(order, nil)

        // Assert
        let actualRequest = testNetwork.actualRequest as! OrderRequest
        XCTAssertEqual(OrderRequest.httpMethod, .post)
        XCTAssertEqual(OrderRequest.path, "/v1/app/order")
        XCTAssertEqual(actualRequest.advertisingId, "00000000-0000-0000-0000-000000000000")
        XCTAssertEqual(actualRequest.attributionToken, "srctok-test")
        XCTAssertEqual(actualRequest.orderId, "order-test")
        XCTAssertEqual(actualRequest.currency, "USD")
        XCTAssertEqual(actualRequest.purchaseDate, "2022-02-01T00:00:00Z")
        XCTAssertEqual(actualRequest.customerOrderId, "cust-order-id-test")
        XCTAssertEqual(actualRequest.customer?.id, "cust-test")
        XCTAssertEqual(actualRequest.customer?.email, "test@example.com".sha256)
        XCTAssertEqual(actualRequest.customer?.isNew, true)
        XCTAssertEqual(actualRequest.lineItems?.first?.id, "item-test")
        XCTAssertEqual(actualRequest.lineItems?.first?.total, 1000)
        XCTAssertEqual(actualRequest.lineItems?.first?.quantity, 1)
        XCTAssertEqual(actualRequest.lineItems?.first?.itemDescription, "1000 pennies")
        XCTAssertEqual(actualRequest.lineItems?.first?.sku, "sku-test")
        XCTAssertEqual(actualRequest.lineItems?.first?.upc, "upc-test")
        XCTAssertEqual(actualRequest.lineItems?.first?.category, ["test"])
        XCTAssertEqual(actualRequest.lineItems?.first?.attributes, ["foo": "bar"])
    }

    func testReportOrderCompletesWithSuccess() {
        waitUntil { done in
            client.reportOrder(Order(id: "order-abc123", purchaseDate: Date(), lineItems: [])) { error in
                XCTAssertNil(error)
                done()
            }
            testNetwork.actualCompletion?([
                "meta": [
                    "status": "ok",
                ]
            ].toData(), nil)
        }
    }

    func testReportOrderCompletesWithError() {
        waitUntil { done in
            client.reportOrder(Order(id: "order-abc123", purchaseDate: Date(), lineItems: [])) { error in
                XCTAssertEqual(error as? TestError, TestError.unknown)
                done()
            }
            testNetwork.actualCompletion?(nil, TestError.unknown)
        }
    }

    func testReportActivityCreatesActivityRequest() {
        // Arrange
        testDefaults.testToken = "srctok-test"
        let product = ButtonProduct()
        product.id = "prod-test"
        product.upc = "upc-test"
        product.categories = ["test"]
        product.name = "1000 pennies"
        product.currency = "USD"
        product.value = 1000
        product.quantity = 1
        product.url = "https://example.com/1000-pennies"
        product.attributes = ["foo": "bar"]

        // Act
        client.reportActivity("activity-test", products: [product])

        // Assert
        let actualRequest = testNetwork.actualRequest as! ActivityRequest
        XCTAssertEqual(actualRequest.btnRef, "srctok-test")
        XCTAssertEqual(actualRequest.activityData.name, "activity-test")
        XCTAssertEqual(actualRequest.activityData.products?.first?.id, "prod-test")
        XCTAssertEqual(actualRequest.activityData.products?.first?.upc, "upc-test")
        XCTAssertEqual(actualRequest.activityData.products?.first?.categories, ["test"])
        XCTAssertEqual(actualRequest.activityData.products?.first?.name, "1000 pennies")
        XCTAssertEqual(actualRequest.activityData.products?.first?.currency, "USD")
        XCTAssertEqual(actualRequest.activityData.products?.first?.value, 1000)
        XCTAssertEqual(actualRequest.activityData.products?.first?.quantity, 1)
        XCTAssertEqual(actualRequest.activityData.products?.first?.url, "https://example.com/1000-pennies")
        XCTAssertEqual(actualRequest.activityData.products?.first?.attributes, ["foo": "bar"])
    }

    func testReportProductViewed() {
        client.productViewed(ButtonProduct.stub())
        let actualRequest = testNetwork.actualRequest as? ActivityRequest
        XCTAssertEqual(actualRequest?.activityData.name, "product-viewed")
        XCTAssertTrue(testNetwork.actualRequest is ActivityRequest)
    }

    func testReportProductAddedToCart() {
        client.productAddedToCart(ButtonProduct.stub())
        let actualRequest = testNetwork.actualRequest as? ActivityRequest
        XCTAssertEqual(actualRequest?.activityData.name, "add-to-cart")
        XCTAssertTrue(testNetwork.actualRequest is ActivityRequest)
    }

    func testReportCartViewed() {
        client.cartViewed([ButtonProduct.stub()])
        let actualRequest = testNetwork.actualRequest as? ActivityRequest
        XCTAssertEqual(actualRequest?.activityData.name, "cart-viewed")
        XCTAssertTrue(testNetwork.actualRequest is ActivityRequest)
    }

    func testReportEventsCreatesEventRequest() {
        // Arrange
        testSystem.testCurrentDate = Date.ISO8601Formatter.date(from: "2022-02-01T00:00:00Z")!
        let event = AppEvent(
            "test-event",
            time: "some time",
            promotionSourceToken: "srctok-test",
            value: ["foo": "bar"],
            uuid: "uuid-test"
        )

        // Act
        client.reportEvents([event], nil)

        // Assert
        let actualRequest = testNetwork.actualRequest as! EventRequest
        XCTAssertEqual(EventRequest.httpMethod, .post)
        XCTAssertEqual(EventRequest.path, "/v1/app/events")
        XCTAssertEqual(actualRequest.events.first?.name, "test-event")
        XCTAssertEqual(actualRequest.events.first?.time, "some time")
        XCTAssertEqual(actualRequest.events.first?.promotionSourceToken, "srctok-test")
        XCTAssertEqual(actualRequest.events.first?.value, ["foo": "bar"])
        XCTAssertEqual(actualRequest.events.first?.uuid, "uuid-test")
        XCTAssertEqual(actualRequest.currentTime, "2022-02-01T00:00:00Z")
    }

    func testEventRequestCompletesSuccess() {
        waitUntil { done in
            let data = [
                "meta": [
                    "status": "ok",
                ]
            ].toData()
            client.reportEvents([AppEvent("test-event", time: "some time")]) { error in
                XCTAssertNil(error)
                done()
            }
            testNetwork.actualCompletion?(data, nil)
        }
    }

    func testEventRequestCompletesError() {
        waitUntil { done in
            client.reportEvents([AppEvent("test-event", time: "some time")]) { error in
                XCTAssertEqual(error as? TestError, TestError.unknown)
                done()
            }
            testNetwork.actualCompletion?(nil, TestError.unknown)
        }
    }

    func testClearAllTasksRemovesNetworkPendingTasks() {
        client.clearAllTasks()
        XCTAssertTrue(testNetwork.didCallClearAllTasks)
    }
}
