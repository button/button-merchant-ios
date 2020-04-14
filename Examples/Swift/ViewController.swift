//
// ViewController.swift
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

import UIKit
import ButtonMerchant

class ViewController: UITableViewController {

    @IBOutlet weak var attributionTokenCell: UITableViewCell!
    @IBOutlet weak var trackIncomingURLCell: UITableViewCell!
    @IBOutlet weak var reportOrderCell: UITableViewCell!
    @IBOutlet weak var clearAllDataCell: UITableViewCell!
    
    var attributionTokenString: String? {
        didSet {
            if let value = attributionTokenString {
                attributionTokenCell.textLabel?.font = UIFont.defaultFont
                attributionTokenCell.textLabel?.text = value
            } else {
                attributionTokenCell.textLabel?.font = UIFont.defaultItalicFont
                attributionTokenCell.textLabel?.text = "no token found"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attributionTokenString = ButtonMerchant.attributionToken
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(attributionTokenDidChange(_:)),
                                               name: Notification.Name.Button.AttributionTokenDidChange,
                                               object: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
                return
        }

        switch cell {
        case trackIncomingURLCell:
            trackIncomingURL()
        case reportOrderCell:
            reportOrder()
        case clearAllDataCell:
            clearAllData()
        default: break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func trackIncomingURL() {
        // Simulates an incoming url with a Button attribution token.
        let srctok = NSUUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        let index = srctok.index(srctok.startIndex, offsetBy: 16)
        UIApplication.shared.openURL(URL(string: "merchant-demo:///?btn_ref=fakesrctok-\(srctok[..<index])")!)
    }

    func reportOrder() {
        let id = NSUUID().uuidString
        let customer = Order.Customer(id: NSUUID().uuidString)
        let order = Order(id: id,
                          purchaseDate: Date(),
                          lineItems: [Order.LineItem(id: NSUUID().uuidString, total: Int64(arc4random_uniform(1000)))])
        order.customer = customer
        ButtonMerchant.reportOrder(order) { (error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    MessageView.showWithTitle("Order Reporting Failed", body: "", in: self.navigationController!.view)
                    return;
                }
                MessageView.showWithTitle("Order Created", body: "Id: \(id)", in: self.navigationController!.view)
            }
        }
    }

    func clearAllData() {
        // Note: In practice, this is only intended to be called when your user logs out.
        ButtonMerchant.clearAllData()
        attributionTokenString = nil
    }
    
    @objc func attributionTokenDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String],
            let newToken = userInfo[Notification.Key.NewToken] else {
                return
        }
        attributionTokenString = newToken
        MessageView.showWithTitle("New Attribution Token", body: newToken, in: self.navigationController!.view)
    }
}

private extension UIFont {
    static let defaultFont = UIFont(name: "Menlo", size: 12.0)
    static let defaultItalicFont = UIFont(name: "Menlo-Italic", size: 12.0)
}
