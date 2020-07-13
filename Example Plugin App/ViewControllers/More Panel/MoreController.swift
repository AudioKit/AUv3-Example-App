//
//  MoreController.swift
//  AU Example App
//
//  Created by Matthew Fecher on 1/15/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit

class MoreController: ControlPanel, ControlPanelProtocol  {

 

    @IBOutlet weak var tuningKnob: ImageKnob!
    @IBOutlet weak var autoPanToggle: ToggleSwitch!
    @IBOutlet weak var autoPanRateKnob: ImageKnob!
    @IBOutlet weak var autoPanDepthKnob: ImageKnob!
    @IBOutlet weak var reverbToggle: ToggleSwitch!
    @IBOutlet weak var reverbSizeKnob: ImageKnob!
    @IBOutlet weak var reverbMixKnob: ImageKnob!

    
    override var allControls: [ParameterController] {
        return [tuningKnob, autoPanToggle, autoPanRateKnob, autoPanDepthKnob, reverbToggle, reverbSizeKnob,
                reverbMixKnob]
    }
    
    override func viewDidAppear(_ animated: Bool) { //fixme: could this be willAppear?
        connectKnobsToParameters()
        super.viewDidAppear(animated)
    }

    func connectKnobsToParameters() {

        tuningKnob.parameter = conductor?.tuningControl
        autoPanDepthKnob.parameter = conductor?.autopanDepthControl
        reverbToggle.parameter = conductor?.reverbEnableControl
        reverbSizeKnob.parameter = conductor?.reverbSizeControl
        reverbMixKnob.parameter = conductor?.reverbMixControl
        autoPanRateKnob.parameter = conductor?.autopanRateControl
        autoPanToggle.parameter = conductor?.autopanEnableControl
    }
}
