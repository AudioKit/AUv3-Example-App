//
//  Parent+PushNotification.swift
//  AudioKit Pro Apps Common
//
//  Created by Matthew Fecher on 1/8/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

import Foundation
import OneSignal
import UIKit
import AudioKit

extension ParentController {

    func pushPopUp() {
        // Add pop up
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            AKLog("User accepted notifications: \(accepted)")
        })

        /*
        let alert = UIAlertController(title: "Stay Informed",
                                      message: "When we have updates, sounds... we'll let you know. Approve notifications!",
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Awesome! 👍🏼", style: .default) { (action: UIAlertAction) in
            self.appSettings.pushNotifications = true
            self.saveAppSettingValues()
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                AKLog("User accepted notifications: \(accepted)")
            })
        }

        let cancelAction = UIAlertAction(title: "Later", style: .default) { (action: UIAlertAction) in
            AKLog("User canceled")
        }
        
        alert.addAction(cancelAction)
        alert.addAction(submitAction)
        
        self.present(alert, animated: true, completion: nil)
        */
    }
}
