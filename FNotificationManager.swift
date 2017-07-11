//
//  FNotificationManager.swift
//  FInAppNotification
//
//  Created by Firas Al Khatib Al Khalidi on 7/4/17.
//  Copyright © 2017 Firas Al Khatib Al Khalidi. All rights reserved.
//

import UIKit
class FNotificationManager: NSObject {
    static let shared                            = FNotificationManager()
    fileprivate var dismissalPanGestureRecognizer: UIPanGestureRecognizer!
    fileprivate var tapGestureRecognizer         : UITapGestureRecognizer!
    private var notificationTimer                : Timer!
    private var settings                         : FNotificationSettings!
    var pauseBetweenNotifications                : TimeInterval = 1
    private var notificationView                     : FNotificationView = UINib(nibName: "FNotificationView",
                                                    bundle: nil).instantiate(withOwner: nil,
                                                                             options: nil).first as! FNotificationView
    private var tapCompletion                    : (()-> Void)?
    private var notificationQueue                : [(FNotification, FNotificationExtensionView?)] = []
    private override init(){
        super.init()
        set(newSettings: .defaultStyle)
        dismissalPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        tapGestureRecognizer          = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        dismissalPanGestureRecognizer.delegate = self
        tapGestureRecognizer.delegate = self
        notificationView.addGestureRecognizer(dismissalPanGestureRecognizer)
        notificationView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer){

        switch gesture.state {
        case .began:
            if notificationTimer != nil{
                notificationTimer.invalidate()
                notificationTimer = nil
            }
        case .changed:
            var translation = gesture.translation(in: notificationView)
            if notificationView.extensionView != nil && !notificationView.isExtended{
                translation.y = translation.y - FNotificationView.bounceOffset
                notificationView.frame.origin.y = translation.y <= 0 ? translation.y : 0
                if translation.y > 0{
                    var notificationHeight = FNotificationView.heightWithStatusBar
                    if UIApplication.shared.isStatusBarHidden{
                        notificationHeight = FNotificationView.heightWithoutStatusBar
                    }
                    let extensionViewHeight: CGFloat = notificationView.extensionView!.height
                    let fullHeight: CGFloat = notificationHeight + translation.y
                    notificationView.frame.size.height = fullHeight <= notificationHeight + extensionViewHeight + 16 ? fullHeight : notificationHeight + extensionViewHeight + 16
                }
            }
            else{
                translation.y = translation.y - FNotificationView.bounceOffset
                notificationView.frame.origin.y = translation.y <= 0 ? translation.y : 0
            }
        case .ended:
            if gesture.velocity(in: notificationView).y < 0{
                notificationTimerExpired()
            }
            else{
                notificationView.isExtended = true
                notificationView.moveToFinalPosition(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer){
        guard notificationView.frame.origin.y == -20 else{
            return
        }
        tapCompletion?()
        notificationTimerExpired()
    }
    
    
    func set(newSettings settings: FNotificationSettings){
        notificationView.backgroundView               = settings.backgroundView
        notificationView.titleLabel.textColor         = settings.titleTextColor
        notificationView.subtitleLabel.textColor      = settings.subtitleTextColor
        notificationView.imageView.layer.cornerRadius = settings.imageViewCornerRadius
        notificationView.titleLabel.font              = settings.titleFont
        notificationView.subtitleLabel.font           = settings.subtitleFont
        notificationView.backgroundColor              = settings.backgroundColor
    }
    
    func show(audioPlayerNotificationWithTitleText titleText: String = "", subtitleText: String = "", image: UIImage? = nil, andDuration duration: TimeInterval = 5, extensionAudioUrl: String, notificationWasTapped: (()-> Void)?, didPlayRecording: (()-> Void)?){
        let audioPlayerExtension = UINib(nibName: "FNotificationVoicePlayerExtensionView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! FNotificationVoicePlayerExtensionView
        audioPlayerExtension.dataUrl          = extensionAudioUrl
        audioPlayerExtension.didPlayRecording = didPlayRecording
        guard notificationView.superview == nil else{
            notificationQueue.append((FNotification(withTitleText: titleText, subtitleText: subtitleText, image: image, duration: duration, notificationWasTapped: notificationWasTapped), audioPlayerExtension))
            return
        }
        notificationView.extensionView            = audioPlayerExtension
        
        defaultShow(withTitleText: titleText,
                    subtitleText: subtitleText,
                    image: image,
                    andDuration: duration,
                    notificationWasTapped: notificationWasTapped)
    }
    
    func show(imageNotificationWithTitleText  titleText: String = "", subtitleText: String = "", image: UIImage? = nil, andDuration duration: TimeInterval = 5, extensionImage: UIImage, notificationWasTapped: (()-> Void)?){
        let imageViewExtentionView = FNotificationImageExtensionView()
        imageViewExtentionView.imageView.image = extensionImage
        guard notificationView.superview == nil else{
            notificationQueue.append((FNotification(withTitleText: titleText, subtitleText: subtitleText, image: image, duration: duration, notificationWasTapped: notificationWasTapped), imageViewExtentionView))
            return
        }
        notificationView.extensionView = imageViewExtentionView
        defaultShow(withTitleText: titleText,
                    subtitleText: subtitleText,
                    image: image,
                    andDuration: duration,
                    notificationWasTapped: notificationWasTapped)
    }
    
    func show(textFieldNotificationWithTitleText titleText: String = "", subtitleText: String = "", image: UIImage? = nil, andDuration duration: TimeInterval = 5, notificationWasTapped: (()-> Void)?, accessoryTextFieldButtonPressed: ((_ text: String)-> Void)?){
        let textFieldExtensionView = UINib(nibName: "FNotificationTextFieldExtensionView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! FNotificationTextFieldExtensionView
        textFieldExtensionView.sendButtonPressed = accessoryTextFieldButtonPressed
        guard notificationView.superview == nil else{
            notificationQueue.append((FNotification(withTitleText: titleText, subtitleText: subtitleText, image: image, duration: duration, notificationWasTapped: notificationWasTapped), textFieldExtensionView))
            return
        }
        notificationView.extensionView = textFieldExtensionView
        defaultShow(withTitleText: titleText,
                    subtitleText: subtitleText,
                    image: image,
                    andDuration: duration,
                    notificationWasTapped: notificationWasTapped)
    }
    
    func show(withTitleText titleText: String = "", subtitleText: String = "", image: UIImage? = nil, andDuration duration: TimeInterval = 5, notificationWasTapped: (()-> Void)?){
        guard notificationView.superview == nil else{
            notificationQueue.append((FNotification(withTitleText: titleText, subtitleText: subtitleText, image: image, duration: duration, notificationWasTapped: notificationWasTapped), nil))
            return
        }
        notificationView.extensionView = nil
        defaultShow(withTitleText: titleText,
                    subtitleText: subtitleText,
                    image: image,
                    andDuration: duration,
                    notificationWasTapped: notificationWasTapped)
    }
    
    func show(notification: FNotification,  withExtensionView extensionView: FNotificationExtensionView, notificationWasTapped: (()-> Void)?, extensionViewInteractionHandlers:(()-> Void)...){
        guard notificationView.superview == nil else{
            notificationQueue.append((notification, nil))
            return
        }
        notificationView.extensionView = extensionView
        defaultShow(withTitleText: notification.titleText,
                    subtitleText: notification.subtitleText,
                    image: notification.image,
                    andDuration: notification.duration,
                    notificationWasTapped: notificationWasTapped)
    }
    func defaultShow(withTitleText titleText: String = "", subtitleText: String = "", image: UIImage? = nil, andDuration duration: TimeInterval = 5, notificationWasTapped: (()-> Void)?){
        notificationView.moveToInitialPosition(animated: false, completion: nil)
        notificationView.titleLabel.text    = titleText
        notificationView.subtitleLabel.text = subtitleText
        notificationView.imageView.image    = image
        tapCompletion = notificationWasTapped
        if notificationTimer != nil{
            self.notificationTimer.invalidate()
            self.notificationTimer = nil
        }
        if UIApplication.shared.isStatusBarHidden{
            notificationView.topConstraint.constant = FNotificationView.topConstraintWithoutStatusBar
            notificationView.frame.size.height      = FNotificationView.heightWithoutStatusBar
            notificationView.layoutIfNeeded()
        }
        else{
            notificationView.topConstraint.constant = FNotificationView.topConstraintWithStatusBar
            notificationView.frame.size.height      = FNotificationView.heightWithStatusBar
            notificationView.layoutIfNeeded()
        }
        guard case let window?? = UIApplication.shared.delegate?.window else{
            return
        }
        
        window.addSubview(notificationView)
        notificationView.moveToFinalPosition(animated: true) {
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
    private func dequeueAndDisplayNotification(){
        guard notificationQueue.count != 0 else{
            return
        }
        let notificationTuple = notificationQueue.removeFirst()
        notificationView.extensionView = notificationTuple.1
        defaultShow(withTitleText: notificationTuple.0.titleText, subtitleText: notificationTuple.0.subtitleText, image: notificationTuple.0.image, andDuration: notificationTuple.0.duration, notificationWasTapped: notificationTuple.0.notificationWasTapped)
    }
    @objc private func notificationTimerExpired(){
        notificationView.moveToInitialPosition(animated: true){
            self.notificationView.removeFromSuperview()
            self.notificationView.extensionView = nil
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + FNotificationManager.shared.pauseBetweenNotifications, execute: {
                self.dequeueAndDisplayNotification()
            })
        }
    }
    func removeCurrentNotification(){
        notificationTimerExpired()
    }
    func removeAllNotifications(){
        notificationQueue = []
        notificationTimerExpired()
    }
}
extension FNotificationManager: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
