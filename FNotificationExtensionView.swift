//
//  FNotificationExtensionView.swift
//  FInAppNotification
//
//  Created by Firas Al Khatib Al Khalidi on 7/5/17.
//  Copyright © 2017 Firas Al Khatib Al Khalidi. All rights reserved.
//

import UIKit
class FNotificationExtensionView: UIView {
    weak var notification: FNotification?
    var heightConstraint: NSLayoutConstraint!
    deinit {
        print("extension view deinited")
    }
}
