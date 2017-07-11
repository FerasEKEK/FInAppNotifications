//
//  FNotification.swift
//  FInAppNotification
//
//  Created by Firas Al Khatib Al Khalidi on 7/11/17.
//  Copyright © 2017 Firas Al Khatib Al Khalidi. All rights reserved.
//

import UIKit
class FNotification {
    var titleText            : String
    var subtitleText         : String
    var image                : UIImage?
    var duration             : TimeInterval
    var notificationWasTapped: (()-> Void)?
    
    init(withTitleText titleText: String = "", subtitleText: String = "", image: UIImage? = nil, duration: TimeInterval = 5, notificationWasTapped: (()-> Void)?) {
        self.titleText             = titleText
        self.subtitleText          = subtitleText
        self.image                 = image
        self.duration              = duration
        self.notificationWasTapped = notificationWasTapped
    }
}
