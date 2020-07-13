//
//  PopUpVelocityController.swift
//  RomPlayer
//
//  Created by Matthew Fecher on 10/29/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import UIKit
import AudioKit

protocol VelocityPopOverDelegate: AnyObject {
    func didFinishSelecting(velocitySetting: KeyboardVelocitySetting)
    func didFinishSelecting(taper: VelocityTaper)
}

enum KeyboardVelocitySetting: Int {
    case fixed, normal, inverted
}

class PopUpVelocityController: UIViewController {

    @IBOutlet weak var velocityTaperSegment: UISegmentedControl!
    @IBOutlet weak var velocitySegment: UISegmentedControl!
    @IBOutlet weak var velocityDescriptionLabel: UILabel!
    
    weak var delegate: VelocityPopOverDelegate?
    var velocitySetting = KeyboardVelocitySetting.fixed
    var velocityTaperSetting = VelocityTaper.normal

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.borderColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        view.layer.borderWidth = 2

        velocitySegment.selectedSegmentIndex = velocitySetting.rawValue
        velocityTaperSegment.selectedSegmentIndex = velocityTaperSetting.rawValue
        
        updateLabelText()
    }

    // Set fonts for UISegmentedControls
    override func viewDidLayoutSubviews() {
        let attr = NSDictionary(object: UIFont(name: "Avenir Next Condensed", size: 16.0)!, forKey: NSAttributedString.Key.font as NSCopying)
        velocitySegment.setTitleTextAttributes(attr as? [NSAttributedString.Key: Any], for: .normal)
    }

    func updateLabelText() {
        switch velocitySetting {
        case .fixed:
            velocityDescriptionLabel.text = "Keyboard will play the same velocity when you tap it different places"
        case .normal:
             velocityDescriptionLabel.text = "Keyboard will trigger higher velocities the further DOWN you tap on a key"
        case .inverted:
            velocityDescriptionLabel.text = "Keyboard will trigger higher velocities the further UP you tap on a key"
        }
    }

    @IBAction func velocityDidChange(_ sender: UISegmentedControl) {
        velocitySetting = KeyboardVelocitySetting(rawValue: sender.selectedSegmentIndex) ?? .fixed

        updateLabelText()
        delegate?.didFinishSelecting(velocitySetting: velocitySetting)
    }

    @IBAction func midiVelocityDidChange(_ sender: UISegmentedControl) {
         velocityTaperSetting = VelocityTaper(rawValue: sender.selectedSegmentIndex) ?? .normal
         delegate?.didFinishSelecting(taper: velocityTaperSetting)
    }

    @IBAction func closeButton(_ sender: UIButton) {
        //conductor.stopNote(note: MIDINoteNumber(60), channel: 0)
        dismiss(animated: true, completion: nil)
    }

}
