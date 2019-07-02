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

internal protocol ClientType: class {
    var network: Network<API> { get }
    var responseHandler: NetworkResponseHandlerType { get }
    func fetchPostInstallURL(parameters: Parameters, _ completion: @escaping (URL?, String?) -> Void)
    func trackOrder(parameters: Parameters, _ completion: ((Error?) -> Void)?)
    func reportOrder(parameters: Parameters, encodedApplicationId: String, _ completion: ((Error?) -> Void)?)
    init(network: Network<API>, responseHandler: NetworkResponseHandlerType)
}

internal final class Client: ClientType {

    var network: Network<API>
    var responseHandler: NetworkResponseHandlerType

    init(network: Network<API>, responseHandler: NetworkResponseHandlerType) {
        self.network = network
        self.responseHandler = responseHandler
    }

    func fetchPostInstallURL(parameters: Parameters, _ completion: @escaping (URL?, String?) -> Void) {
        network.request(.postInstall(parameters: parameters)) { [weakSelf = self] data, response, error in

            if let response = response as? HTTPURLResponse {
                let result = weakSelf.responseHandler.handleResponse(response)
                switch result {
                case .success:
                    guard let data = data,
                        let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let object = responseDict?["object"] as? [String: Any],
                        let action = object["action"] as? String,
                        let attributionObject = object["attribution"] as? [String: Any],
                        let sourceToken = attributionObject["btn_ref"] as? String else {
                            completion(nil, nil)
                            return
                    }
                    completion(URL(string: action)!, sourceToken)
                case .failure:
                    completion(nil, nil)
                }
            } else {
                completion(nil, nil)
            }
        }
    }

    func trackOrder(parameters: Parameters, _ completion: ((Error?) -> Void)?) {
        network.request(.activity(parameters: parameters)) { [weakSelf = self] data, response, error in

            guard let completion = completion else {
                return
            }

            if error != nil {
                completion(error)
                return
            }

            if let response = response as? HTTPURLResponse {
                let result = weakSelf.responseHandler.handleResponse(response)
                switch result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            } else {
                completion(ClientError.emptyResponse)
            }
        }
    }

    func reportOrder(parameters: Parameters, encodedApplicationId: String, _ completion: ((Error?) -> Void)?) {
        network.request(.order(parameters: parameters, encodedAppId: encodedApplicationId)) { [weakSelf = self] data, response, error in

            guard let completion = completion else {
                return
            }

            if error != nil {
                completion(error)
                return
            }

            if let response = response as? HTTPURLResponse {
                let result = weakSelf.responseHandler.handleResponse(response)
                switch result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            } else {
                completion(ClientError.emptyResponse)
            }
        }
    }

}
