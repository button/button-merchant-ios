//
// Client.swift
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

import Foundation
import UIKit
import Core

internal protocol ClientType: Activity {
    var applicationId: ApplicationId? { get set }
    var defaults: ButtonDefaultsType { get }
    var system: SystemType { get }
    var network: NetworkType { get }
    func fetchPostInstallURL(_ completion: @escaping (URL?, String?) -> Void)
    func reportOrder(_ order: Order, _ completion: ((Error?) -> Void)?)
    func reportEvents(_ events: [AppEvent], _ completion: ((Error?) -> Void)?)
    func reportActivity(_ name: String, products: [ButtonProduct]?)
    func clearAllTasks()
    init(defaults: ButtonDefaultsType,
         system: SystemType,
         network: NetworkType)
}

internal final class Client: ClientType {

    var defaults: ButtonDefaultsType
    var system: SystemType
    var network: NetworkType

    var applicationId: ApplicationId? {
        didSet {
            network.applicationId = applicationId
        }
    }

    init(defaults: ButtonDefaultsType,
         system: SystemType,
         network: NetworkType) {
        self.defaults = defaults
        self.system = system
        self.network = network
    }

    func fetchPostInstallURL(_ completion: @escaping (URL?, String?) -> Void) {
        network.fetch(PostInstallRequest()) { data, _ in
            guard let object = PostInstallResponse.from(data)?.object,
                  let action = object.action,
                  let token = object.attribution?.btnRef else {
                      OperationQueue.main.addOperation {
                          completion(nil, nil)
                      }
                      return
            }
            OperationQueue.main.addOperation {
                completion(action, token)
            }
        }
    }

    func reportOrder(_ order: Order, _ completion: ((Error?) -> Void)?) {
        let orderRequest = OrderRequest(
            advertisingId: system.advertisingId,
            attributionToken: defaults.attributionToken,
            order: order
        )

        network.fetch(orderRequest, retryPolicy: RetryPolicy(retries: 4)) { _, error in
            completion?(error)
        }
    }

    func reportEvents(_ events: [AppEvent], _ completion: ((Error?) -> Void)?) {
        guard events.count > 0 else {
            return
        }
        network.fetch(
            EventRequest(
                ifa: system.advertisingId,
                events: events, currentTime:
                    system.currentDate.ISO8601String
            )
        ) { _, error in
            completion?(error)
        }
    }
}

// MARK: Activity

extension Client {

    func productViewed(_ product: ButtonProductCompatible?) {
        reportActivity("product-viewed", products: [product?.productRepresentation()].compactMap { $0 })
    }

    func productAddedToCart(_ product: ButtonProductCompatible?) {
        reportActivity("add-to-cart", products: [product?.productRepresentation()].compactMap { $0 })
    }

    func cartViewed(_ products: [ButtonProductCompatible]?) {
        reportActivity("cart-viewed", products: products?.map { $0.productRepresentation() })
    }

    func reportActivity(_ name: String, products: [ButtonProduct]?) {
        network.fetch(
            ActivityRequest(
                ifa: system.advertisingId,
                btnRef: defaults.attributionToken,
                activityData: .init(name: name, products: products)
            )
        )
    }
}

// MARK: Cleanup

extension Client {
    func clearAllTasks() {
        network.clearAllTasks()
    }
}
