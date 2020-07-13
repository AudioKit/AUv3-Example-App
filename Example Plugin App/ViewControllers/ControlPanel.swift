//
//  ControlPanel.swift
//  AU Example App
//
//  Created by Jeff Cooper on 2/10/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit
protocol ControlPanelProtocol: class {
    var includedParams: [BaseParameter] { get }
    var allControls: [ParameterController]  { get }
    func connectKnobsToParameters()
}

class ControlPanel: UIViewController {


    var includedParams: [BaseParameter] {
        return allControls.compactMap({$0.parameter?.baseParameter})
    }
    var allControls: [ParameterController] { return [ParameterController]() }

    private var isLoaded = false
    var conductor: Conductor?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCallbacks()
        updateAllKnobs()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isLoaded {
            updateAllKnobs()
            setPresetValues()
        }
        isLoaded = true
        addListeners()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeListeners()
    }

    @objc private func receivedNotif(_ notification: Notification) {
        if let dict = notification.userInfo as? [String : Any],
            let value = dict["normalized"] as? Float,
            let param = dict["param"] as? BaseParameter, let instrumentID = notification.object as? String {
            if instrumentID == conductor?.exampleInstrument.uid {
                updateKnobViaParam(param, value: value)
            }
        }
    }

    private func addListeners() {
        for param in includedParams {
            addListener(for: param)
        }
    }

    private func addListener(for param: BaseParameter) {
        LocalNotificationCenter.sharedInstance.center.addObserver(self, selector: #selector(receivedNotif(_:)),
                                                                  name: param.notificationName,
                                                                  object: nil)
    }
    private func removeListeners() {
        LocalNotificationCenter.sharedInstance.center.removeObserver(self)
    }

    func updateAllKnobs() {
        for param in includedParams {
            updateKnobViaParam(param)
        }
    }

    func updateKnobViaParam(_ param: BaseParameter, value: Float? = nil) {
        for control in allControls {
            if control.parameter?.baseParameter == param, let parameter = control.parameter {
                updateController(control: control, value: value ?? parameter.value)
            }
        }
    }

    func updateController(control: ParameterController, value: Float) {
        DispatchQueue.main.async {
            if let knob = control as? MIDIKnob {
                knob.knobValue = CGFloat(value)
            } else if let toggle = control as? ToggleSwitch  {
                toggle.isOn = value > 0
            }
        }
    }

    private func setupCallbacks() {
        for control in allControls {
            control.callback = {value in
                control.parameter?.value = Float(value)
            }
        }
    }

    func setPresetValues() {
        for control in allControls {
            if let presetValue = control.parameter?.value, let knob = control as? Knob {
                knob.presetKnobValue = CGFloat(presetValue)
            }
        }
    }
}
