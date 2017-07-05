//
//  FNotificationSettings.swift
//  FInAppNotification
//
//  Created by Firas Al Khatib Al Khalidi on 7/4/17.
//  Copyright © 2017 Firas Al Khatib Al Khalidi. All rights reserved.
//

import UIKit
class FNotificationSettings {
    ///background view of the notification
    var backgroundView       : UIView?
    ///background color of the notification
    var backgroundColor      : UIColor = .lightGray
    ///title text color of the notification
    var titleTextColor       : UIColor = .black
    ///subtitle color of the notification
    var subtitleTextColor    : UIColor = .black
    ///corner radius of the image view of the notification
    var imageViewCornerRadius: CGFloat = 0
    ///font for the title text
    var titleFont            = UIFont.boldSystemFont(ofSize: 17)
    ///font of the subtitle text
    var subtitleFont         = UIFont.systemFont(ofSize: 13)
    ///universal initializer for the settings object, has default values
    init(backgroundView: UIView? = nil, backgroundColor: UIColor = .lightGray, titleTextColor: UIColor = .black, subtitleTextColor: UIColor = .black, imageViewCornerRadius: CGFloat = 25, titleFont: UIFont = UIFont.boldSystemFont(ofSize: 17), subtitleFont: UIFont = UIFont.systemFont(ofSize: 13)){
        self.backgroundView        = backgroundView
        self.backgroundColor       = backgroundColor
        self.titleTextColor        = titleTextColor
        self.subtitleTextColor     = subtitleTextColor
        self.imageViewCornerRadius = imageViewCornerRadius
        self.titleFont             = titleFont
        self.subtitleFont          = subtitleFont
    }
    ///default style for the notification, set as the style of the notification settings at the beginning
    static var defaultStyle: FNotificationSettings{
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView   = UIVisualEffectView(effect: blurEffect)
        return FNotificationSettings(backgroundView: blurView,
                                     backgroundColor: .clear,
                                     titleTextColor: .white,
                                     subtitleTextColor: .white)
    }
    
}
