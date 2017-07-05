//
//  ViewController.swift
//  FInAppNotification
//
//  Created by Firas Al Khatib Al Khalidi on 7/4/17.
//  Copyright © 2017 Firas Al Khatib Al Khalidi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let uuidString = UUID().uuidString
        counter = (counter+1) % 3
        if counter == 0{
            FNotificationManager.shared.show(withTitleText: "Firas", subtitleText: uuidString, image: #imageLiteral(resourceName: "pp"), notificationWasTapped: {
                print("Notification Tapped")
            })
        }
        else if counter == 1 {
            FNotificationManager.shared.show(textFieldNotificationWithTitleText: "Firas", subtitleText: uuidString, image: #imageLiteral(resourceName: "pp"), notificationWasTapped: {
                (sender as! UIButton).setTitle(uuidString, for: .normal)
            }) { (text) in
                (sender as! UIButton).setTitle(text, for: .normal)
            }
        }
        else{
            FNotificationManager.shared.show(imageNotificationWithTitleText: "Firas", subtitleText: "Sent you an image", image: #imageLiteral(resourceName: "pp"), extensionImage: #imageLiteral(resourceName: "bunnyrabbit"), notificationWasTapped: {
                print("Image notification was tapped")
            })
        }

    
    }
}

