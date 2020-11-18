//
//  ParentController.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/14/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
import Disk

class ParentController: UIViewController {

    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var mainButton: TopNavButton!
    @IBOutlet weak var moreButton: TopNavButton!
    @IBOutlet weak var aboutButton: TopNavButton!
    @IBOutlet weak var pitchPad: AKVerticalPad!
    @IBOutlet weak var modWheelPad: AKVerticalPad!
    @IBOutlet weak var settingsButton: SynthUIButton!
    @IBOutlet weak var configureKeyboardButton: SynthUIButton!
    @IBOutlet weak var velocityButton: SynthUIButton!
    @IBOutlet weak var wheelsButton: SynthUIButton!
    @IBOutlet weak var midiPanicButton: PresetUIButton!
    @IBOutlet weak var midiLearnButton: NavButton!
    @IBOutlet weak var holdToggle: SynthUIButton!
    @IBOutlet weak var octaveStepper: Stepper!
    @IBOutlet weak var keyboardView: SynthKeyboard!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var headsUpView: UIView!
    @IBOutlet weak var bluetoothButton: AKBluetoothMIDIButton!
    @IBOutlet weak var saveButton: PresetUIButton!
    @IBOutlet weak var keyboardContainerView: KeyboardContainer!
    @IBOutlet weak var keyboardTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideKeyboardButton: UIButton!

    var topNavButtons = [TopNavButton]()
    var topChildView: ChildView?
    var prevTopChildView: ChildView?
    var midiKnobs = [MIDIKnob]()
    var conductor: Conductor? {
        didSet {
            mainController.conductor = conductor
            moreController.conductor = conductor
            presetsController.conductor = conductor
        }
    }

    var appSettings = AppSetting()
    var isLoaded = false

    var isPresetsPanelVisible = false
    var presetsList = PresetsManager.shared

    // **********************************************************
    // MARK: - Add Child Views
    // **********************************************************

    weak var mainControllerCache: MainController?

    private var makeMainController: MainController {
        let storyboard = UIStoryboard(name: "MainPanel", bundle: Bundle.main)
        mainControllerCache = storyboard.instantiateViewController(withIdentifier: ChildView.mainView.identifier()) as? MainController
        return mainControllerCache!
    }

    var mainController: MainController {
        return mainControllerCache ?? makeMainController
    }

    weak var moreControllerCache: MoreController?

    private var makeMoreController: MoreController {
        let storyboard = UIStoryboard(name: "MorePanel", bundle: Bundle.main)
        moreControllerCache = storyboard.instantiateViewController(withIdentifier: ChildView.moreView.identifier()) as? MoreController
        return moreControllerCache!
    }

    var moreController: MoreController {
        return moreControllerCache ?? makeMoreController
    }

    weak var presetsControllerCache: PresetsController?

    private var makePresetsController: PresetsController {
        let storyboard = UIStoryboard(name: "PresetsPanel", bundle: Bundle.main)
        presetsControllerCache = storyboard.instantiateViewController(withIdentifier: ChildView.presetsView.identifier()) as? PresetsController
        return presetsControllerCache!
    }

    var presetsController: PresetsController {
        return presetsControllerCache ?? makePresetsController
    }

    weak var aboutControllerCache: AboutController?

    private var makeAboutController: AboutController {
        let storyboard = UIStoryboard(name: "About", bundle: Bundle.main)
        aboutControllerCache = storyboard.instantiateViewController(withIdentifier: ChildView.aboutView.identifier()) as? AboutController
        return aboutControllerCache!
    }

    var aboutController: AboutController {
        return aboutControllerCache ?? makeAboutController
    }

    // **********************************************************
    // MARK: - Life Cycle
    // **********************************************************

    override func viewDidLoad() {
        super.viewDidLoad()
        deboog("Standalone VC didLoad")

        #if Standalone
        if AKManager.engine.isRunning {
            try? AKManager.stop() //just being thorough
        }
        AKSettings.sampleRate = AKManager.deviceSampleRate // important
        if conductor == nil {
            conductor = Conductor()
        }
        AKManager.output = conductor?.exampleInstrument.output
        conductor?.setSession()
        conductor?.startEngine()
        conductor?.midi.addListener(self)
        if let conductor = conductor { conductor.midi.addListener(conductor) }
        conductor?.registerForNotifications()
        bluetoothButton.centerPopupIn(view: view)
        #endif

        // Setup Keyboard 🎹
        keyboardView?.delegate = self
        keyboardView?.polyphonicMode = true
        keyboardView?.firstOctave = 2
        octaveStepper.minValue = -2
        octaveStepper.maxValue = 3

        // Setup Top Nav Buttons
        topNavButtons += view.allSubViewsOf(type: TopNavButton.self)
        topNavButtons.forEach { $0.alternateButtons = topNavButtons }
        mainButton.unselectAlternateButtons()
        mainButton.value = 1
        headsUpView.layer.cornerRadius = 4
        headsUpView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        // Add Gesture Recognizer to Display Label for Presets Popup
        let tap = UITapGestureRecognizer(target: self, action: #selector(ParentController.displayLabelTapped))
        tap.numberOfTapsRequired = 1
        displayLabel.addGestureRecognizer(tap)

        // Make bluetooth button look pretty
        bluetoothButton.layer.cornerRadius = 2
        bluetoothButton.layer.borderWidth = 1

        setupCallbacks()

        // ModWheel
        modWheelPad.resetToPosition(0.5, 0.0)

        // Load SubViews
        switchToChildView(.moreView)
        switchToChildView(.presetsView)
        switchToChildView(.mainView)

        // Scale Up iPad Views using 4:3 ratio
        if UIDevice.current.userInterfaceIdiom == .pad {
            let iPadHeight: CGFloat = 768
            let iPadWidth: CGFloat = 1024

            let xRatio = (UIScreen.main.bounds.height * 4/3) / iPadWidth
            let yRatio = UIScreen.main.bounds.height / iPadHeight

            self.view.transform = CGAffineTransform.identity.scaledBy(x: xRatio, y: yRatio)

            // Anchor view to 0,0 origin
            view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        guard !isLoaded else { return }

        // Load App Settings
        if Disk.exists("settings.json", in: .sharedContainer(appGroupName: FileConstants.sharedContainer)) {
            loadSettingsFromDevice()
        } else {
            setDefaultsFromAppSettings()
            saveAppSettings()
        }

        #if Standalone
        if let lastLoadedPreset = presetsList.getPresetVia(position: appSettings.currentPresetIndex) {
            conductor?.loadPreset(lastLoadedPreset)
        }
        #else
        // TODO: Set preset from State?
        #endif

        // Increase number of launches
        appSettings.launches = appSettings.launches + 1

        // Get MIDI Knobs
        midiKnobs += mainController.view.allSubViewsOf(type: MIDIKnob.self)
        midiKnobs += moreController.view.allSubViewsOf(type: MIDIKnob.self)

        self.isLoaded = true
        addListeners()

        // Increase Buffer size on devices
        let modelName = UIDevice.current.modelName
        if appSettings.firstRun && modelName == "iPad 4" {
            AKSettings.bufferLength = .veryLong
            try? AVAudioSession.sharedInstance().setPreferredIOBufferDuration(AKSettings.bufferLength.duration)
        } else if appSettings.firstRun && (UIDevice.current.userInterfaceIdiom == .pad) {
            AKSettings.bufferLength = .long
            try? AVAudioSession.sharedInstance().setPreferredIOBufferDuration(AKSettings.bufferLength.duration)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // Hide home indicator when not in the area
    override public var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    private func addListeners() {
        for param in BaseParameter.allCases {
            addListener(for: param)
        }
        LocalNotificationCenter.sharedInstance.center.addObserver(self, selector: #selector(receivedNoteOn(_:)),
                                                                  name: .KeyPressedViaMIDI, object: nil)
        LocalNotificationCenter.sharedInstance.center.addObserver(self, selector: #selector(receivedNoteOff(_:)),
                                                                  name: .KeyReleasedViaMIDI, object: nil)
        LocalNotificationCenter.sharedInstance.center.addObserver(self, selector: #selector(receivedModwheel(_:)),
                                                                  name: .ModWheelViaMIDI, object: nil)
        LocalNotificationCenter.sharedInstance.center.addObserver(self, selector: #selector(receivedPitchbend(_:)),
                                                                  name: .PitchbendViaMIDI, object: nil)
        LocalNotificationCenter.sharedInstance.center.addObserver(self, selector: #selector(presetLoadedNotification(_:)),
                                                                  name: .PresetLoaded, object: nil)
        LocalNotificationCenter.sharedInstance.center.addObserver(self, selector: #selector(MIDIKnobTouched(_:)),
                                                                  name: .MIDIKnobTouched, object: nil)
    }

    @objc private func MIDIKnobTouched(_ notification: Notification) {
        updateDisplay("MIDI Learn: Move control on device")
    }

    @objc private func presetLoadedNotification(_ notification: Notification) {
        guard conductor?.exampleInstrument.uid == notification.object as? String else { return }
        if let dict = notification.userInfo as? [String : Any],
            let preset = dict["preset"] as? InstrumentPreset {
            updateDisplay(preset.name)
            appSettings.currentPresetIndex = conductor?.currentPreset?.position ?? 0
            saveAppSettings()
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

    @objc private func receivedModwheel(_ notification: Notification) {
        if let dict = dictFromValidNotification(notification), let value = dict["modwheel"] as? MIDIByte  {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.modWheelPad.setVerticalValueFrom(midiValue: value, sendCallback: false)
            }
        }
    }
    @objc private func receivedPitchbend(_ notification: Notification) {
        if let dict = dictFromValidNotification(notification), let value = dict["pitchBend"] as? Float  {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.pitchPad.setVerticalValueFrom(normalized: Double(value), sendCallback: false)
            }
        }
    }
    @objc private func receivedNoteOn(_ notification: Notification) {
        if let dict = dictFromValidNotification(notification), let noteNumber = dict["key"] as? MIDINoteNumber {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.keyboardView.pressAdded(noteNumber, sendToDelegate: false)
            }
        }
    }

    @objc private func receivedNoteOff(_ notification: Notification) {
        if let dict = dictFromValidNotification(notification), let noteNumber = dict["key"] as? MIDINoteNumber {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.keyboardView.pressRemoved(noteNumber, sendToDelegate: false)
            }
        }
    }

    @objc private func receivedNotif(_ notification: Notification) {
        if let dict = dictFromValidNotification(notification) {
            if let value = dict["normalized"] as? Float, let param = dict["param"] as? BaseParameter { //parameter
                updateDisplayWith(param, value: value)
            }
        }
    }

    private func isNotificationValid(_ notification: Notification) -> Bool {
        if let exampleInstrumentID = notification.object as? String, exampleInstrumentID == conductor?.exampleInstrument.uid {
            return true
        }
        return false
    }

    private func dictFromValidNotification(_ notification: Notification) -> [String : Any]? {
        if isNotificationValid(notification), let dict = notification.userInfo as? [String : Any] {
            return dict
        }
        return nil
    }

    // *********************************************************
     // MARK: – IB Actions
     // *********************************************************

     @objc func displayLabelTapped() {
         self.topNavButtons.forEach { $0.value = 0 }

         if !isPresetsPanelVisible {
             prevTopChildView = topChildView
             switchToChildView(.presetsView)
             mainButton.unselectAlternateButtons()
         } else {
             switchToChildView(self.prevTopChildView!)
         }
     }

     @IBAction func rightPresetPressed() {
         presetsController.nextPreset()
     }

     @IBAction func leftPresetPressed() {
         presetsController.prevPreset()
     }

     @IBAction func AppNameTapped(_ sender: UIButton) {
         mainButton.unselectAlternateButtons()
         mainButton.value = 1
         switchToChildView(.mainView)
     }

    @IBAction func showKeyboardTapped(_ sender: UIButton) {
        // Hide/Show Keyboard
        var newConstraintValue: CGFloat = 210
        if hideKeyboardButton.isSelected {
            keyboardView.topKeyHeightRatio = 0.45
        } else {
            newConstraintValue = 36
            keyboardView.topKeyHeightRatio = 0.50
        }

        let prevLabelMode = keyboardView.labelMode
        keyboardView.labelMode = 0
        keyboardView.setNeedsDisplay()

        UIView.animate(withDuration: Double(0.3), animations: {
            self.keyboardTopConstraint.constant = newConstraintValue
            self.view.layoutIfNeeded()
        }, completion: { [weak self] (finished: Bool) in
            guard let strongSelf = self else { return }
            strongSelf.keyboardView.labelMode = prevLabelMode
            strongSelf.keyboardView.setNeedsDisplay()
            strongSelf.pitchPad.resetToCenter()
            strongSelf.modWheelPad.setVerticalValueFrom(normalized: strongSelf.modWheelPad.verticalValue)
        })

        hideKeyboardButton.isSelected.toggle()
    }

    // *********************************************************
    // MARK: – Helpers
    // *********************************************************

    func updateDisplay(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.displayLabel.text = message
            strongSelf.displayLabel.setNeedsDisplay()
        }
    }

    private func updateDisplayWith(_ param: BaseParameter, value: Float) {
        if let exampleInstrumentParam = conductor?.getRhodesParameterFrom(baseParam: param) {
            let outString = exampleInstrumentParam.displayValueFor(normalized: value)
            updateDisplay("\(exampleInstrumentParam.name): \(outString)")
        }
    }

    func stopAllNotes() {
        keyboardView.allNotesOff()
        for note in 0 ... 127 {
            conductor?.exampleInstrument.stopNote(noteNumber: MIDINoteNumber(note), channel: 0, offset: 0)
        }
    }

    // *********************************************************
    // MARK: – ChildViews
    // *********************************************************

    func add(asChildViewController viewController: UIViewController, isTopContainer: Bool = true) {
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        topContainerView.addSubview(viewController.view)
        viewController.view.frame = topContainerView.bounds

        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }

    func switchToChildView(_ newView: ChildView, isTopView: Bool = true) {
        if let preset = presetsController.presetFromConductor {
            updateDisplay(preset.name)
        }

        // remove all child views
        for view in topContainerView.subviews { view.removeFromSuperview() }

        switch newView {
        case .mainView:
            add(asChildViewController: mainController)
        case .moreView:
            add(asChildViewController: moreController)
        case .aboutView:
            add(asChildViewController: aboutController)
        case .presetsView:
            add(asChildViewController: presetsController)
            isPresetsPanelVisible = true
        }

        if newView != .presetsView {
            topChildView = newView
            isPresetsPanelVisible = false
        }

    }
}
