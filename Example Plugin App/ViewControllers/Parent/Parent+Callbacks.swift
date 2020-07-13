//
//  Parent+Callbacks.swift
//  AU Example App
//
//  Created by Matthew Fecher on 1/23/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

// **********************************************************
// MARK: - Callbacks
// **********************************************************

extension ParentController  {

    func setupCallbacks() {

        mainButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.switchToChildView(.mainView)
        }

        moreButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.switchToChildView(.moreView)
        }

        aboutButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.switchToChildView(.aboutView)
        }

        saveButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            // Displays save pop-up 
            strongSelf.presetsController.saveIconPressed()
        }

        octaveStepper.callback = { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.keyboardView.firstOctave = Int(value) + 2
        }

        settingsButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: "SegueToSettingsPopOver", sender: self)
            strongSelf.settingsButton.value = 0
        }

        wheelsButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.wheelsButton.value = 0
            strongSelf.performSegue(withIdentifier: "SegueToMod", sender: self)
        }

        velocityButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: "SegueToVelocityPopOver", sender: self)
            strongSelf.velocityButton.value = 0
        }

        holdToggle.callback = { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.keyboardView.holdMode.toggle()
            if value == 0.0 {
                strongSelf.stopAllNotes()
            }
        }

        configureKeyboardButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.configureKeyboardButton.value = 0
            strongSelf.performSegue(withIdentifier: "SegueToKeySettingsPopOver", sender: strongSelf)
        }

        midiPanicButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }

            strongSelf.stopAllNotes()
            strongSelf.displayAlertController("Midi Panic", message: "All notes have been turned off.")
        }

        midiLearnButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }

            // Toggle MIDI Learn Knobs in all views
            strongSelf.midiKnobs.forEach { $0.midiLearnMode = strongSelf.midiLearnButton.isSelected }

            // Update display label
            if strongSelf.midiLearnButton.isSelected {
                strongSelf.updateDisplay("MIDI Learn: Touch a knob to assign")
            } else {
                strongSelf.updateDisplay("MIDI Learn Off")
                strongSelf.updateAndSaveAppSettings()
            }
        }

        modWheelPad.callback = { [weak self] value in
            guard let strongSelf = self else { return }

            strongSelf.conductor?.setModwheel(MIDIByte(normalized: value))
        }

        pitchPad.callback = { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.conductor?.setPitchBend(normalized: Float(value))
        }

        pitchPad.completionHandler = {  [weak self] _, touchesEnded, reset in
            guard let strongSelf = self else { return }
            if touchesEnded && !reset {
                strongSelf.pitchPad.resetToCenter()
            }
            if reset {
                strongSelf.conductor?.exampleInstrument.pitchBend = 0.0
            }
        }
    }
}
