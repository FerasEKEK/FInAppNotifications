//
//  FNotificationTextFieldExtensionView.swift
//  FInAppNotification
//
//  Created by Apple on 7/5/17.
//  Copyright © 2017 *TechnologySARL. All rights reserved.
//

import UIKit
class FNotificationTextFieldExtensionView: FNotificationExtensionView {
    @IBOutlet weak var textField : UITextField!
    @IBOutlet weak var sendButton: UIButton!
    var sendButtonPressed        : ((_ text: String)-> Void)?
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sendButtonPressed?(textField.text ?? "")
        self.notification?.moveToInitialPosition(animated: true){
            self.notification?.removeFromSuperview()
            self.notification?.extensionView = nil
        }
    }
}
