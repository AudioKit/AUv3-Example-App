//
//  UIViewController+DisplayAlertController.swift
//  RadioInformer
//
//  Created by Matthew Fecher on 5/1/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit
import StoreKit
import AudioKit

extension UIViewController {

    func displayAlertController(_ title: String, message: String) {
        // Create and display alert box
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func reviewPopUp() {
        // Add pop up
        let alert = UIAlertController(title: "Thank you",
                                      message: "You are amazing. If you like the sounds in this app, please give the app a nice review. \n\n It helps our efforts to bring free music-making to kids and people who can not afford them. \n\n It is because of you that all this is possible! Thanks for being awesome.",
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Cool 👍🏼", style: .default) { (action: UIAlertAction) in
            self.requestReview()
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .default) { (action: UIAlertAction) in
            AKLog("User canceled")
        }
        
        alert.addAction(cancelAction)
        alert.addAction(submitAction)

        self.present(alert, animated: true, completion: nil)
    }

    func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            if let url = URL(string: "https://itunes.apple.com/app/apple-store/id1307785646?mt=8") {
  //              UIApplication.shared.open(url)
            }
        }
    }

    func skRequestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}
