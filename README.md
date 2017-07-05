**NFLoadingController** 
===
In app notifications for ios written using swift. Supports textfield, images, and normal notifications 

**What it looks like**
=
![](demo.gif)


**Usage**
=
```
        let uuidString = UUID().uuidString
        counter = (counter+1) % 3
        if counter == 0{
            FNotificationManager.shared.show(withTitleText: "Firas",
                                             subtitleText: uuidString,
                                             image: #imageLiteral(resourceName: "pp"),
                                             notificationWasTapped: {
                print("Notification Tapped")
            })
        }
        else if counter == 1 {
            FNotificationManager.shared.show(textFieldNotificationWithTitleText: "Firas",
                                             subtitleText: uuidString,
                                             image: #imageLiteral(resourceName: "pp"),
                                             notificationWasTapped: {
                (sender as! UIButton).setTitle(uuidString, for: .normal)
            }) { (text) in
                (sender as! UIButton).setTitle(text, for: .normal)
            }
        }
        else{
            FNotificationManager.shared.show(imageNotificationWithTitleText: "Firas",
                                             subtitleText: "Sent you an image",
                                             image: #imageLiteral(resourceName: "pp"),
                                             extensionImage: #imageLiteral(resourceName: "bunnyrabbit"),
                                             notificationWasTapped: {
                print("Image notification was tapped")
            })
        }

```

**Requirement**
=
- iOS 9.0+
- Swift 3.0

**How to add**
=
-Just drag the project files to your project.

**License**
=
This software is released under the MIT License.
