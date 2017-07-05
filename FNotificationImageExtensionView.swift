//
//  FNotificationImageExtensionView.swift
//  FInAppNotification
//
//  Created by Firas Al Khatib Al Khalidi on 7/5/17.
//  Copyright © 2017 Firas Al Khatib Al Khalidi. All rights reserved.
//

import UIKit

class FNotificationImageExtensionView: FNotificationExtensionView {
    var imageView: UIImageView
    override init(frame: CGRect) {
        imageView = UIImageView()
        super.init(frame: frame)
        setupImageView()
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageView = UIImageView()
        super.init(coder: aDecoder)
        setupImageView()
        backgroundColor = .clear
    }
    
    private func setupImageView(){
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints                           = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive                   = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive    = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive             = true
        imageView.contentMode                                                         = .scaleAspectFill
        imageView.clipsToBounds                                                       = true
    }
}
