//
//  AudioUnitViewController.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/8/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AUAudioUnit?
    var conductor: Conductor? {
        return (audioUnit as? ExampleApp_AudioUnit)?.conductor
    }

    @IBOutlet weak var containerView: UIView!

    weak var parentControllerCache: ParentController?

    private var makeParentController: ParentController {
        let storyboard = UIStoryboard(name: "Parent", bundle: Bundle.main)
        let vcName = "ParentController"
        parentControllerCache = storyboard.instantiateViewController(withIdentifier: vcName) as? ParentController
        return parentControllerCache!
    }

    private var parentVC: ParentController? {
        return parentControllerCache ?? makeParentController
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        deboog("AU VC didLoad")

        addEmbeddedParentVC()
        
        if audioUnit == nil {
            return
        }

        parentVC?.conductor = conductor
//        if let firstPreset = presetsList.sortedPresets.first { conductor?.loadPreset(firstPreset) }
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }

    func addEmbeddedParentVC() {
        // Add Child View Controller
        guard let parentVC = parentVC else { return }
        addChild(parentVC)

        // Add Child View as Subview
        containerView.addSubview(parentVC.view)
        parentVC.view.frame = containerView.bounds
        parentVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentVC.didMove(toParent: self)
    }
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        deboog("createAudioUnit with from AUVC")
        audioUnit = try ExampleApp_AudioUnit(componentDescription: componentDescription, options: [])

        parentVC?.conductor = conductor
//        if let firstPreset = presetsList.sortedPresets.first { conductor?.loadPreset(firstPreset) }
        return audioUnit!
    }
    
}
