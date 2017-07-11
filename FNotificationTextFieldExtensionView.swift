//
//  FNotificationTextFieldExtensionView.swift
//  FInAppNotification
//
//  Created by Firas Al Khatib Al Khalidi on 7/5/17.
//  Copyright © 2017 *TechnologySARL. All rights reserved.
//

import UIKit
class FNotificationTextFieldExtensionView: FNotificationExtensionView {
    @IBOutlet weak var textField : UITextField!
    @IBOutlet weak var sendButton: UIButton!
    override var height: CGFloat{
        return 40
    }
    var sendButtonPressed        : ((_ text: String)-> Void)?
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sendButtonPressed?(textField.text ?? "")
        self.notificationView?.moveToInitialPosition(animated: true){
            self.notificationView?.removeFromSuperview()
            self.notificationView?.extensionView = nil
        }
    }
}
