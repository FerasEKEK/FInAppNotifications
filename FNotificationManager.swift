//
//  FNotificationManager.swift
//  FInAppNotification
//
//  Created by Apple on 7/4/17.
//  Copyright © 2017 *TechnologySARL. All rights reserved.
//

import UIKit
class FNotificationManager: NSObject {
    static let shared                            = FNotificationManager()
    fileprivate var dismissalPanGestureRecognizer: UIPanGestureRecognizer!
    fileprivate var tapGestureRecognizer         : UITapGestureRecognizer!
    private var notificationTimer                : Timer!
    private var settings                         : FNotificationSettings!
    private var notification                     : FNotification = UINib(nibName: "FNotification",
                                                    bundle: nil).instantiate(withOwner: nil,
                                                                             options: nil).first as! FNotification
    private var tapCompletion                    : (()-> Void)?
    private override init(){
        super.init()
        set(newSettings: .defaultStyle)
        dismissalPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        tapGestureRecognizer          = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        dismissalPanGestureRecognizer.delegate = self
        tapGestureRecognizer.delegate = self
        notification.addGestureRecognizer(dismissalPanGestureRecognizer)
        notification.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer){

        switch gesture.state {
        case .began:
            if notificationTimer != nil{
                notificationTimer.invalidate()
                notificationTimer = nil
            }
        case .changed:
            var translation = gesture.translation(in: notification)
            if notification.extensionView != nil && !notification.isExtended{
                translation.y = translation.y - FNotification.bounceOffset
                notification.frame.origin.y = translation.y <= 0 ? translation.y : 0
                if translation.y > 0{
                    var notificationHeight = FNotification.heightWithStatusBar
                    if UIApplication.shared.isStatusBarHidden{
                        notificationHeight = FNotification.heightWithoutStatusBar
                    }
                    var accessoryViewHeight: CGFloat = 0
                    if notification.extensionView! is FNotificationTextFieldExtensionView{
                        accessoryViewHeight = FNotification.textFieldExtensionViewHeight
                    }
                    else if notification.extensionView is FNotificationImageExtensionView{
                        accessoryViewHeight = FNotification.imageViewExtensionViewHeight
                    }
                    let fullHeight: CGFloat = notificationHeight + translation.y
                    notification.frame.size.height = fullHeight <= notificationHeight + accessoryViewHeight + 16 ? fullHeight : notificationHeight + accessoryViewHeight + 16
                }
            }
            else{
                translation.y = translation.y - FNotification.bounceOffset
                notification.frame.origin.y = translation.y <= 0 ? translation.y : 0
            }
        case .ended:
            if gesture.velocity(in: notification).y < 0{
                notificationTimerExpired()
            }
            else{
                notification.isExtended = true
                notification.moveToFinalPosition(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer){
        guard notification.frame.origin.y == -20 else{
            return
        }
        tapCompletion?()
        notificationTimerExpired()
    }
    
    
    func set(newSettings settings: FNotificationSettings){
        notification.backgroundView               = settings.backgroundView
        notification.titleLabel.textColor         = settings.titleTextColor
        notification.subtitleLabel.textColor      = settings.subtitleTextColor
        notification.imageView.layer.cornerRadius = settings.imageViewCornerRadius
        notification.titleLabel.font              = settings.titleFont
        notification.subtitleLabel.font           = settings.subtitleFont
        notification.backgroundColor              = settings.backgroundColor
    }
    
    func show(imageNotificationWithTitleText  titleText: String = "", subtitleText: String = "", image: UIImage? = nil, andDuration duration: TimeInterval = 5, extensionImage: UIImage, notificationWasTapped: (()-> Void)?){
        let imageViewExtentionView = FNotificationImageExtensionView()
        imageViewExtentionView.imageView.image = extensionImage
        notification.extensionView = imageViewExtentionView
        if notificationTimer != nil{
            self.notificationTimer.invalidate()
            self.notificationTimer = nil
        }
        if UIApplication.shared.isStatusBarHidden{
            notification.topConstraint.constant = FNotification.topConstraintWithoutStatusBar
            notification.frame.size.height      = FNotification.heightWithoutStatusBar
            notification.layoutIfNeeded()
        }
        else{
            notification.topConstraint.constant = FNotification.topConstraintWithStatusBar
            notification.frame.size.height      = FNotification.heightWithStatusBar
            notification.layoutIfNeeded()
        }
        let window = UIApplication.shared.delegate?.window
        guard window != nil else{
            return
        }
        guard window! != nil else{
            return
        }
        notification.moveToInitialPosition(animated: false, completion: nil)
        notification.titleLabel.text    = titleText
        notification.subtitleLabel.text = subtitleText
        notification.imageView.image    = image
        window!!.addSubview(notification)
        tapCompletion = notificationWasTapped
        notification.moveToFinalPosition(animated: true) {
            if self.notificationTimer != nil{
                self.notificationTimer.invalidate()
                self.notificationTimer = nil
            }
            self.notificationTimer = Timer.scheduledTimer(timeInterval: duration,
                                                          target: self,
                                                          selector: #selector(self.notificationTimerExpired),
                                                          userInfo: nil,
                                                          repeats: false)
        }
    }
    
    func show(textFieldNotificationWithTitleText titleText: String = "", subtitleText: String = "", image: UIImage? = nil, andDuration duration: TimeInterval = 5, notificationWasTapped: (()-> Void)?, accessoryTextFieldButtonPressed: ((_ text: String)-> Void)?){
        let textFieldExtensionView = UINib(nibName: "FNotificationTextFieldExtensionView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! FNotificationTextFieldExtensionView
        textFieldExtensionView.sendButtonPressed = accessoryTextFieldButtonPressed
        notification.extensionView = textFieldExtensionView
        if notificationTimer != nil{
            self.notificationTimer.invalidate()
            self.notificationTimer = nil
        }
        if UIApplication.shared.isStatusBarHidden{
            notification.topConstraint.constant = FNotification.topConstraintWithoutStatusBar
            notification.frame.size.height      = FNotification.heightWithoutStatusBar
            notification.layoutIfNeeded()
        }
        else{
            notification.topConstraint.constant = FNotification.topConstraintWithStatusBar
            notification.frame.size.height      = FNotification.heightWithStatusBar
            notification.layoutIfNeeded()
        }
        let window = UIApplication.shared.delegate?.window
        guard window != nil else{
            return
        }
        guard window! != nil else{
            return
        }
        notification.moveToInitialPosition(animated: false, completion: nil)
        notification.titleLabel.text    = titleText
        notification.subtitleLabel.text = subtitleText
        notification.imageView.image    = image
        window!!.addSubview(notification)
        tapCompletion = notificationWasTapped
        notification.moveToFinalPosition(animated: true) {
            if self.notificationTimer != nil{
                self.notificationTimer.invalidate()
                self.notificationTimer = nil
            }
            self.notificationTimer = Timer.scheduledTimer(timeInterval: duration,
                                                          target: self,
                                                          selector: #selector(self.notificationTimerExpired),
                                                          userInfo: nil,
                                                          repeats: false)
        }
    }
    
    func show(withTitleText titleText: String = "", subtitleText: String = "", image: UIImage? = nil, andDuration duration: TimeInterval = 5, notificationWasTapped: (()-> Void)?){
        notification.extensionView = nil
        if notificationTimer != nil{
            self.notificationTimer.invalidate()
            self.notificationTimer = nil
        }
        if UIApplication.shared.isStatusBarHidden{
            notification.topConstraint.constant = FNotification.topConstraintWithoutStatusBar
            notification.frame.size.height      = FNotification.heightWithoutStatusBar
            notification.layoutIfNeeded()
        }
        else{
            notification.topConstraint.constant = FNotification.topConstraintWithStatusBar
            notification.frame.size.height      = FNotification.heightWithStatusBar
            notification.layoutIfNeeded()
        }
        let window = UIApplication.shared.delegate?.window
        guard window != nil else{
            return
        }
        guard window! != nil else{
            return
        }
        notification.moveToInitialPosition(animated: false, completion: nil)
        notification.titleLabel.text    = titleText
        notification.subtitleLabel.text = subtitleText
        notification.imageView.image    = image
        window!!.addSubview(notification)
        tapCompletion = notificationWasTapped
        notification.moveToFinalPosition(animated: true) {
            if self.notificationTimer != nil{
                self.notificationTimer.invalidate()
                self.notificationTimer = nil
            }
            self.notificationTimer = Timer.scheduledTimer(timeInterval: duration,
                                                          target: self,
                                                          selector: #selector(self.notificationTimerExpired),
                                                          userInfo: nil,
                                                          repeats: false)
        }
    }
    
    @objc private func notificationTimerExpired(){
        notification.moveToInitialPosition(animated: true){
            self.notification.removeFromSuperview()
            self.notification.extensionView = nil
        }
    }
}
extension FNotificationManager: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
