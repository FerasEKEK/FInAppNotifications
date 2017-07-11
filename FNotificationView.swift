//
//  FNotification.swift
//  FInAppNotification
//
//  Created by Firas Al Khatib Al Khalidi on 7/4/17.
//  Copyright © 2017 Firas Al Khatib Al Khalidi. All rights reserved.
//

import UIKit
class FNotificationView: UIView {
    static let bounceOffset                  : CGFloat = 20
    static let heightWithStatusBar           : CGFloat = 120
    static let heightWithoutStatusBar        : CGFloat = 100
    static let topConstraintWithStatusBar    : CGFloat = 48
    static let topConstraintWithoutStatusBar : CGFloat = 28
    static let extensionViewTopConstraint    : CGFloat = 16

    @IBOutlet weak var imageView             : UIImageView!
    @IBOutlet weak var topConstraint         : NSLayoutConstraint!
    @IBOutlet weak var titleLabel            : UILabel!
    @IBOutlet weak var subtitleLabel         : UILabel!
    
    @IBOutlet weak var extensionViewIndicator: UIView!
    
    var isExtended                           = false
    var extensionView                        : FNotificationExtensionView?{
        didSet{
            oldValue?.removeFromSuperview()
            if oldValue != nil{
                if let audioExtension = oldValue as? FNotificationVoicePlayerExtensionView{
                    audioExtension.audioPlayer.pause()
                    if audioExtension.timeObserver != nil{
                        audioExtension.audioPlayer.removeTimeObserver(audioExtension.timeObserver!)
                    }
                    audioExtension.timeObserver = nil
                    audioExtension.audioPlayer = nil
                }
            }
            isExtended = false
            extensionViewIndicator.isHidden = true
            
            guard extensionView != nil else{
                return
            }
            extensionView?.notificationView = self
            extensionViewIndicator.isHidden = false
            addSubview(extensionView!)
            extensionView!.translatesAutoresizingMaskIntoConstraints                                     = false
            extensionView!.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: FNotificationView.extensionViewTopConstraint).isActive = true
            extensionView!.leftAnchor.constraint(equalTo: leftAnchor).isActive                           = true
            extensionView!.rightAnchor.constraint(equalTo: rightAnchor).isActive                         = true
            extensionView!.heightAnchor.constraint(equalToConstant: extensionView!.height).isActive = true
        }
    }
    var isAnimating                         = false
    var backgroundView                      : UIView?{
        didSet{
            oldValue?.removeFromSuperview()
            guard backgroundView != nil else{
                return
            }
            insertSubview(backgroundView!, at: 0)
            backgroundView!.translatesAutoresizingMaskIntoConstraints               = false
            backgroundView!.topAnchor.constraint(equalTo: topAnchor).isActive       = true
            backgroundView!.leftAnchor.constraint(equalTo: leftAnchor).isActive     = true
            backgroundView!.rightAnchor.constraint(equalTo: rightAnchor).isActive   = true
            backgroundView!.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    func moveToInitialPosition(animated: Bool, completion : (()-> Void)?){
        guard animated else{
            frame.origin.y = -frame.size.height
            return
        }
        isAnimating = true
        UIView.animate(withDuration: 0.2, animations: {
            self.frame.origin.y = -self.frame.size.height
        }) { (completed) in
            self.isAnimating = false
            completion?()
        }
    }
    
    func moveToFinalPosition(animated: Bool, completion: (()-> Void)?){
        guard animated else{
            frame.origin.y = -20
            frame.size.height = height
            return
        }
        isAnimating = true
        UIView.animate(withDuration: 0.2, animations: {
            self.frame.origin.y = -20
            self.frame.size.height = self.height
        }) { (completed) in
            self.isAnimating = false
            completion?()
        }
    }
    
    override func layoutSubviews() {
        frame.origin.x = 0
        frame.size.width = UIScreen.main.bounds.width
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    var height: CGFloat{
        var notificationHeight: CGFloat = 0
        if UIApplication.shared.isStatusBarHidden{
            notificationHeight = FNotificationView.heightWithoutStatusBar
            topConstraint.constant = FNotificationView.topConstraintWithoutStatusBar
        }
        else{
            notificationHeight = FNotificationView.heightWithStatusBar
            topConstraint.constant = FNotificationView.topConstraintWithStatusBar
        }
        var extensionViewHeight: CGFloat = 0
        if isExtended && extensionView != nil{
            extensionViewHeight = extensionView!.height + 16
        }
        let height = notificationHeight + extensionViewHeight
        return height
    }
    func orientationChanged(){
        frame.origin.y = -20
        frame.size.height = height
        guard extensionView != nil else{
            return
        }
    }
}
