//
//  Parent+Segues.swift
//  AU Example App
//
//  Created by Matthew Fecher on 1/18/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit

extension ParentController {

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "SegueToKeySettingsPopOver" {
            let popOverController = segue.destination as! PopUpKeySettingsController
            popOverController.delegate = self
            popOverController.octaveRange = keyboardView.octaveCount
            popOverController.labelMode = keyboardView.labelMode
            popOverController.darkMode = keyboardView.darkMode
            popOverController.preferredContentSize = CGSize(width: 410, height: 408)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
                presentation.sourceRect = configureKeyboardButton.bounds
            }
        }

        if segue.identifier == "SegueToSettingsPopOver" {
            let popOverController = segue.destination as! PopUpMIDIController
               popOverController.delegate = self
               guard let conductor = conductor else { return }
               let userMIDIChannel = conductor.omniMode ? -1 : Int(conductor.midiChannelIn)
               popOverController.userChannelIn = userMIDIChannel
            // popOverController.midiSources = midiInputs
            popOverController.backgroundAudioEnabled = conductor.backgroundAudioEnabled

            popOverController.preferredContentSize = CGSize(width: 660, height: 330)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
                presentation.sourceRect = settingsButton.bounds
            }
        }

        if segue.identifier == "SegueToVelocityPopOver" {
            let popOverController = segue.destination as! PopUpVelocityController
            popOverController.delegate = self
            popOverController.velocitySetting = keyboardView.velocitySetting
            popOverController.velocityTaperSetting = VelocityTaper(actualTaper: conductor?.velocityTaper ?? 1.0)
            popOverController.preferredContentSize = CGSize(width: 340, height: 330)

            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
                presentation.sourceRect = velocityButton.bounds
            }
        }

        if segue.identifier == "SegueToMod" {
            let popOverController = segue.destination as! PopUpMODController
            popOverController.delegate = self
            popOverController.modWheelDestination = conductor?.modwheelDest.rawValue ?? 0
            popOverController.pitchBendUpperSemitones = conductor?.pitchBendUpperSemitones ?? AudioConstants.pitchBendSemitonesDefault
            popOverController.pitchBendLowerSemitones = -1.0 * (conductor?.pitchBendLowerSemitones ?? AudioConstants.pitchBendSemitonesDefault)

            popOverController.preferredContentSize = CGSize(width: 380, height: 340)

            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
                presentation.sourceRect = wheelsButton.bounds
            }
        }

    }

}
