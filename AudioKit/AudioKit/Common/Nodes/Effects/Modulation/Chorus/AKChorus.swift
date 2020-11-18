//
//  AKChorus.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Shane's Chorus
///
open class AKChorus: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKChorusAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "chrs")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var depthParameter: AUParameter?
    fileprivate var feedbackParameter: AUParameter?
    fileprivate var dryWetMixParameter: AUParameter?

    public static let frequencyRange = Double(kAKChorus_MinFrequency) ... Double(kAKChorus_MaxFrequency)
    public static let depthRange = Double(kAKChorus_MinDepth) ... Double(kAKChorus_MaxDepth)
    public static let feedbackRange = Double(kAKChorus_MinFeedback) ... Double(kAKChorus_MaxFeedback)
    public static let dryWetMixRange = Double(kAKChorus_MinDryWetMix) ... Double(kAKChorus_MaxDryWetMix)

    public static let defaultFrequency = Double(kAKChorus_DefaultFrequency)
    public static let defaultDepth = Double(kAKChorus_DefaultDepth)
    public static let defaultFeedback = Double(kAKChorus_DefaultFeedback)
    public static let defaultDryWetMix = Double(kAKChorus_DefaultDryWetMix)

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Modulation Frequency (Hz)
    @objc open dynamic var frequency: Double = defaultFrequency {
        willSet {
            guard frequency != newValue else { return }
            if internalAU?.isSetUp == true {
                frequencyParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.frequency, value: newValue)
        }
    }

    /// Modulation Depth (fraction)
    @objc open dynamic var depth: Double = defaultDepth {
        willSet {
            guard depth != newValue else { return }
            if internalAU?.isSetUp == true {
                depthParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.depth, value: newValue)
        }
    }

    /// Feedback (fraction)
    @objc open dynamic var feedback: Double = defaultFeedback {
        willSet {
            guard feedback != newValue else { return }
            if internalAU?.isSetUp == true {
                feedbackParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.feedback, value: newValue)
        }
    }

    /// Dry Wet Mix (fraction)
    @objc open dynamic var dryWetMix: Double = defaultDryWetMix {
        willSet {
            guard dryWetMix != newValue else { return }
            if internalAU?.isSetUp == true {
                dryWetMixParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.dryWetMix, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this chorus node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be processed
    ///   - frequency: modulation frequency Hz
    ///   - depth: depth of modulation (fraction)
    ///   - feedback: feedback fraction
    ///   - dryWetMix: fraction of wet signal in mix
    ///
    @objc public init(
        _ input: AKNode? = nil,
        frequency: Double = defaultFrequency,
        depth: Double = defaultDepth,
        feedback: Double = defaultFeedback,
        dryWetMix: Double = defaultDryWetMix
    ) {

        self.frequency = frequency
        self.depth = depth
        self.feedback = feedback
        self.dryWetMix = dryWetMix

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        frequencyParameter = tree["frequency"]
        depthParameter = tree["depth"]
        feedbackParameter = tree["feedback"]
        dryWetMixParameter = tree["dryWetMix"]

        internalAU?.setParameterImmediately(.frequency, value: frequency)
        internalAU?.setParameterImmediately(.depth, value: depth)
        internalAU?.setParameterImmediately(.feedback, value: feedback)
        internalAU?.setParameterImmediately(.dryWetMix, value: dryWetMix)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
