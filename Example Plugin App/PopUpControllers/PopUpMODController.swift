//
//  PopUpMODController.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 12/26/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

protocol ModWheelDelegate: AnyObject {
    func didSelectRouting(newDestination: Int)
    func pitchbendUpperDidChange(newMax: Double)
    func pitchBendLowerDidChange(newMin: Double)
}

class PopUpMODController: UIViewController {

    @IBOutlet weak var modWheelSegment: UISegmentedControl!
    @IBOutlet weak var bendUpperRangeStepper: Stepper!
    @IBOutlet weak var bendLowerRangeStepper: Stepper!

    weak var delegate: ModWheelDelegate?
    var modWheelDestination = 0
    var pitchBendUpperSemitones = AudioConstants.pitchBendSemitonesDefault
    var pitchBendLowerSemitones = AudioConstants.pitchBendSemitonesDefault
    

    override func viewDidLoad() {
        super.viewDidLoad()

        modWheelSegment.selectedSegmentIndex = modWheelDestination

        // Setup Stepper Ranges
        bendUpperRangeStepper.maxValue = Double(AudioConstants.pitchBendSemitonesMaxDefault)
        bendUpperRangeStepper.minValue = 0
        bendLowerRangeStepper.maxValue = 0
        bendLowerRangeStepper.minValue = Double(-1.0 * AudioConstants.pitchBendSemitonesMaxDefault)

        // Callbacks
        bendUpperRangeStepper.callback = { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.pitchbendUpperDidChange(newMax: value)
        }

        bendLowerRangeStepper.callback = { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.pitchBendLowerDidChange(newMin: -value)
        }

    }
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)

          bendUpperRangeStepper.value = Double(pitchBendUpperSemitones)
          bendLowerRangeStepper.value = Double(pitchBendLowerSemitones)
      }

    @IBAction func routingValueDidChange(_ sender: UISegmentedControl) {
        delegate?.didSelectRouting(newDestination: sender.selectedSegmentIndex)
    }

    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
