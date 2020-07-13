//
//  AboutController.swift
//  AU Example App
//
//  Created by Matthew Fecher on 1/16/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit
import MessageUI

class AboutController: UIViewController {

    @IBOutlet weak var contactButton: PresetUIButton!
    @IBOutlet weak var websiteButton: PresetUIButton!
    @IBOutlet weak var videoButton: PresetUIButton!
    @IBOutlet weak var infoButton: PresetUIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCallbacks()
    }

    func setupCallbacks() {

        contactButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            let receipients = ["hello@audiokitpro.com"]
            let subject = "From example App"
            let messageBody = ""

            let configuredMailComposeViewController = strongSelf.configureMailComposeViewController(recepients: receipients, subject: subject, messageBody: messageBody)

            if strongSelf.canSendMail() {
                strongSelf.present(configuredMailComposeViewController, animated: true, completion: nil)
            } else {
                strongSelf.showSendMailErrorAlert()
            }
        }

        websiteButton.callback = { _ in
            if let url = URL(string: "https://audiokitpro.com/") {
 //               UIApplication.shared.open(url)
            }
        }


    }

}

//*****************************************************************
// MARK: - MFMailComposeViewController Delegate
//*****************************************************************

extension AboutController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }

    func configureMailComposeViewController(recepients: [String], subject: String, messageBody: String) -> MFMailComposeViewController {

        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(recepients)
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody(messageBody, isHTML: false)

        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

        sendMailErrorAlert.addAction(cancelAction)
        present(sendMailErrorAlert, animated: true, completion: nil)
    }
}

