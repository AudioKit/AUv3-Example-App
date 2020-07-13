//
//  PopUpMIDIController.swift
//  RomPlayer
//
//  Created by Matthew Fecher on 10/22/17.
//  Copyright © 2017 Matthew Fecher. All rights reserved.
//

import AudioKit
import UIKit

protocol MIDISettingsPopOverDelegate: AnyObject {
    func resetMIDILearn()
    func didSelectMIDIChannel(newChannel: Int)
    func didToggleBackgroundAudio(state: Bool)
    func didResetPresets()
    func didSetBuffer()
}

class PopUpMIDIController: UIViewController {

    @IBOutlet weak var channelStepper: Stepper!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var resetButton: SynthUIButton!
    @IBOutlet weak var inputTable: UITableView!
    @IBOutlet weak var midiTipsButton: SynthUIButton!
    @IBOutlet weak var sleepToggle: ToggleSwitch!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var backgroundAudioToggle: ToggleSwitch!
    @IBOutlet weak var restoreFactoryPresets: SynthUIButton!
    @IBOutlet weak var bufferSizeSegmentedControl: UISegmentedControl!

    weak var delegate: MIDISettingsPopOverDelegate?

    var midiSources = [MIDIInput]() {
        didSet {
            displayMIDIInputs()
        }
    }
    var userChannelIn: Int = 1
    var backgroundAudioEnabled: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.borderColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)
        view.layer.borderWidth = 2
        inputTable.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)

        // setup channel stepper
        userChannelIn += 1 // Internal MIDI Channels start at 0...15, Users see 1...16
        channelStepper.maxValue = 16
        channelStepper.value = Double(userChannelIn)
        updateChannelLabel()

        // Setup Callbacks
        setupCallbacks()
    }

    override func viewWillAppear(_ animated: Bool) {
        displayMIDIInputs()

        bufferSizeSegmentedControl.selectedSegmentIndex = AKSettings.bufferLength.rawValue - BufferLength.shortest.rawValue
        bufferSizeSegmentedControl.setNeedsDisplay()

        #if Standalone
        sleepToggle.isOn = UIApplication.shared.isIdleTimerDisabled
        backgroundAudioToggle.isOn = backgroundAudioEnabled
        #else
        sleepToggle.isOn = false
        #endif

        if sleepToggle.isOn {
            self.backgroundAudioToggle.alpha = 0.0
            self.energyLabel.alpha = 0.0
        }
    }

    func displayMIDIInputs() {
        if self.isViewLoaded && (self.view.window != nil) {
            // viewController is visible
            inputTable.reloadData()
        }
    }

    // **********************************************************
    // MARK: - Callbacks
    // **********************************************************

    func setupCallbacks() {
        // Setup Callback
        channelStepper.callback = { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.userChannelIn = Int(value)
            strongSelf.updateChannelLabel()
            strongSelf.delegate?.didSelectMIDIChannel(newChannel: strongSelf.userChannelIn - 1)
        }

        resetButton.callback = { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.resetMIDILearn()
            strongSelf.resetButton.value = 0
            strongSelf.displayAlertController("MIDI Learn Reset", message: "All MIDI learn knob assignments have been removed.")
        }

        midiTipsButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.midiTipsButton.value = 0
            strongSelf.performSegue(withIdentifier: "SegueToMIDITips", sender: strongSelf)
        }

        sleepToggle.callback = { [weak self] value in
            guard let strongSelf = self else { return }

            #if Standalone
            if value == 1 {
                UIApplication.shared.isIdleTimerDisabled = true
                let title = NSLocalizedString("Don't Sleep Mode", comment: "Alert Title: Allows On Mode")
                let message = NSLocalizedString("This mode is great for playing live. " +
                    "Background audio will also stay on. " +
                    "Note: It will use more power and could drain your battery faster",
                                                comment: "Alert Message: Allows On Mode")

                strongSelf.displayAlertController(title, message: message)

                strongSelf.backgroundAudioToggle.alpha = 0.0
                strongSelf.energyLabel.alpha = 0.0
            } else {
                UIApplication.shared.isIdleTimerDisabled = false
                strongSelf.backgroundAudioToggle.alpha = 1.0
                strongSelf.energyLabel.alpha = 1.0

            }

            #else

            let title = NSLocalizedString("Don't Sleep Mode", comment: "Alert Title: Don't Sleep Mode")
            let message = NSLocalizedString("This mode is only available in stand alone mode.", comment: "Alert Message: Dont Sleep Mode AU")
            strongSelf.displayAlertController(title, message: message)

            #endif
        }

        backgroundAudioToggle.callback = { [weak self] value in
            guard let strongSelf = self else { return }
            if value == 1 {
                let title = NSLocalizedString("Important", comment: "Alert Title: Background Audio")
                let message = NSLocalizedString(
                    "Background audio will drain the battery faster. Please turn off when not in use.",
                    comment: "Alert Message: Background Audio")
                strongSelf.displayAlertController(title, message: message)
            }
            //      strongSelf.conductor.backgroundAudioOn = value == 1
            strongSelf.delegate?.didToggleBackgroundAudio(state: value == 1)
        }

        restoreFactoryPresets.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            // Add pop up
            let alert = UIAlertController(title: "Restore Presets",
                                          message: "Are you sure you want to restore the Factory Presets? Note: This will not overwrite your custom created/named presets",
                                          preferredStyle: .alert)
            let submitAction = UIAlertAction(title: "Okay! 👍🏼", style: .default) { (_: UIAlertAction) in
                AKLog("reset presets")
                strongSelf.delegate?.didResetPresets()
                strongSelf.displayAlertController("Presets Restored", message: "The factory presets have been restored to their original settings.")
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_: UIAlertAction) in
                AKLog("User canceled")
            }

            alert.addAction(cancelAction)
            alert.addAction(submitAction)

            strongSelf.present(alert, animated: true, completion: nil)
            strongSelf.restoreFactoryPresets.value = 0
        }
    }

    func updateChannelLabel() {
        if userChannelIn == 0 {
            self.channelLabel.text = "MIDI Channel In: Omni"
        } else {
            self.channelLabel.text = "MIDI Channel In: \(userChannelIn)"
        }
    }

    // **********************************************************
    // MARK: - Actions
    // **********************************************************

    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func bufferSizeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            //      conductor.updateDisplayLabel("Buffer Size: 32")
            AKSettings.bufferLength = .shortest
        case 1:
            //       conductor.updateDisplayLabel("Buffer Size: 64")
            AKSettings.bufferLength = .veryShort
        case 2:
            //        conductor.updateDisplayLabel("Buffer Size: 128")
            AKSettings.bufferLength = .short
        case 3:
            //        conductor.updateDisplayLabel("Buffer Size: 256")
            AKSettings.bufferLength = .medium
        case 4:
            //        conductor.updateDisplayLabel("Buffer Size: 512")
            AKSettings.bufferLength = .long
        case 5:
            //       conductor.updateDisplayLabel("Buffer Size: 1024")
            AKSettings.bufferLength = .veryLong
        default:
            break
        }

        do {
            try AKTry {
                try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(AKSettings.bufferLength.duration)
            }
        } catch let error as NSError {
            AKLog("AKSettings Error: Cannot set Preferred IOBufferDuration to " +
                "\(AKSettings.bufferLength.duration) ( = \(AKSettings.bufferLength.samplesCount) samples)")
            AKLog("AKSettings Error: \(error))")
        }

        // Save Settings
        delegate?.didSetBuffer()
    }

}

// *****************************************************************
// MARK: - TableViewDataSource
// *****************************************************************

extension PopUpMIDIController: UITableViewDataSource {

    func numberOfSections(in categoryTableView: UITableView) -> Int {
        return 1
    }

    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if midiSources.isEmpty {
            return 0
        } else {
            return midiSources.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "MIDICell") as? MIDICell {

            let midiInput = midiSources[indexPath.row]

            cell.configureCell(midiInput: midiInput)

            return cell

        } else {
            return MIDICell()
        }
    }
}

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension PopUpMIDIController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        // presetIndex = (indexPath as NSIndexPath).row

        // Get cell
        let cell = tableView.cellForRow(at: indexPath) as? MIDICell
        guard let midiInput = cell?.currentInput else { return }

        // Toggle Cell
        midiInput.isOpen.toggle()
        inputTable.reloadData()

        // Open / Close MIDI Input
        if midiInput.isOpen {
            //          conductor.midi.openInput(name: midiInput.name)
        } else {
            //conductor.midi.closeInput(name: midiInput.name)

        }

    }

}
