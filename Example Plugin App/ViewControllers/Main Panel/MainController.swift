//
//  MainController.swift
//  AU Example App
//
//  Created by Matthew Fecher on 1/14/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit

class MainController: ControlPanel, ControlPanelProtocol {

    @IBOutlet weak var mainVolumeKnob: MIDIKnob!
    @IBOutlet weak var attackKnob: MIDIKnob!
    @IBOutlet weak var decayKnob: MIDIKnob!
    @IBOutlet weak var sustainKnob: MIDIKnob!
    @IBOutlet weak var releaseKnob: MIDIKnob!
    @IBOutlet weak var tremoloRateKnob: MIDIKnob!
    @IBOutlet weak var tremoloDepthKnob: MIDIKnob!
    @IBOutlet weak var stereoWidenToggle: ToggleSwitch!

    override var allControls: [ParameterController] {
        return [mainVolumeKnob, attackKnob, decayKnob, sustainKnob, releaseKnob, tremoloRateKnob, tremoloDepthKnob, stereoWidenToggle]
    }

    override func viewDidAppear(_ animated: Bool) {
        connectKnobsToParameters()
        super.viewDidAppear(animated)
    }

    func connectKnobsToParameters() {
        mainVolumeKnob.parameter = conductor?.volumeMainControl
        attackKnob.parameter = conductor?.attackControl
        decayKnob.parameter = conductor?.decayControl
        sustainKnob.parameter = conductor?.sustainControl
        releaseKnob.parameter = conductor?.releaseControl
        tremoloRateKnob.parameter = conductor?.tremoloRateControl
        tremoloDepthKnob.parameter = conductor?.tremoloDepthControl
        stereoWidenToggle.parameter = conductor?.stereoWidenEnableControl
    }
}
