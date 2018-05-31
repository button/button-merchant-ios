//
// MessageView.swift
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

class MessageView: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    
    private var visibilityConstraint: NSLayoutConstraint?
    
    class func showWithTitle(_ title: String, body: String, in view: UIView) {
        let messageView = (Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)?.first as? MessageView)!
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageView.titleLabel.text = title
        messageView.bodyLabel.text = body
        messageView.showIn(view)
    }
    
    private func showIn(_ view: UIView) {
        view.addSubview(self)
        
        let margins = view.layoutMarginsGuide
        leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 8.0).isActive = true
        trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8.0).isActive = true
        let bottomConstraint = bottomAnchor.constraint(equalTo: margins.topAnchor, constant: -64.0)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
        
        visibilityConstraint = topAnchor.constraint(equalTo: margins.topAnchor, constant: 8.0)
        
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.350,
                       delay: 0.0,
                       usingSpringWithDamping: 0.70,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseIn,
                       animations: {
                        self.visibilityConstraint?.isActive = true
                        view.layoutIfNeeded()
                       }, completion: { _ in
                        delay(3.0, closure: {
                            self.hide()
                        })
                       })
    }
    
    func hide() {
        guard let view = superview else {
            return
        }
        
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.30) {
            self.visibilityConstraint?.isActive = false
            view.layoutIfNeeded()
        }
    }

}

func delay(_ delay: Double, closure: @escaping () -> Void) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
