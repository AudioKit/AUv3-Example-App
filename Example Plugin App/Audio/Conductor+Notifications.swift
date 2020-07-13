//
//  Conductor+Notifications.swift
//  Bass 808
//
//  Created by Jeff Cooper on 3/17/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import AudioKit

extension Conductor {
    func registerForNotifications() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleInterruption),
//                                               name: AVAudioSession.interruptionNotification,
//                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sleepIfNeeded),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wakeIfNeeded),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc internal func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                let message = "Got an interruption but non-standard info \(String(describing: notification.userInfo))"
                deboog(message)
                return
        }
        if type == .began {
            stopEngine()
            postInterruptionBeganNotification()
            deboog("interrup began")
        } else if type == .ended {
            startEngine()
            postInterruptionEndedNotification()
            deboog("interrup ended")
        } else {
            deboog("type : \(type)")
        }
    }

    @objc internal func handleRouteChange(_ notification: Notification) {
        if notification.name == Notification.Name.AVAudioEngineConfigurationChange {
            let message = "Got a AVAudioEngineConfigurationChange - add a reset() here?"
            deboog(message)
            return
        }
        guard let info = notification.userInfo,
            let reasonValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                let message = "Got a ROUTE CHANGE but non-standard info \(String(describing: notification))"
                deboog(message)
                return
        }
        switch reason {
        case .newDeviceAvailable:
            reset()
        case .oldDeviceUnavailable:
            reset()
        default:
            break
        }
        postRouteChangeNotification() //update views / viewControllers - AFTER handling audio engine
    }

    func reset() {
        stopEngine()
        startEngine()
    }
    func isBluetoothDeviceConnected() -> Bool {
        return AVAudioSession.sharedInstance().currentRoute.outputs.map({ $0.portType }).contains(where: {
            [AVAudioSession.Port.bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains($0)
        })
    }

    internal func postReadyNotification() {
        postNotification(name: .audioEngineReady)
    }

    internal func postEngineDownNotification() {
        postNotification(name: .audioEngineDown)
    }

    internal func postInterruptionBeganNotification() {
        postNotification(name: .audioInterruptionBegan)
    }

    internal func postInterruptionEndedNotification() {
        postNotification(name: .audioInterruptionEnded)
    }

    internal func postRouteChangeNotification() {
        postNotification(name: .audioRouteChange)
    }

    private func postNotification(name: Notification.Name) {
        LocalNotificationCenter.sharedInstance.center.post(
            name: name,
            object: self,
            userInfo: nil )
    }
}

extension Notification.Name {
    static let audioEngineReady = NSNotification.Name(rawValue: "AudioEngineReady")
    static let audioEngineDown = NSNotification.Name(rawValue: "AudioEngineDown")
    //the below are optional for more fine control
    static let audioRouteChange = NSNotification.Name(rawValue: "AudioRouteChange")
    static let audioInterruptionBegan = NSNotification.Name(rawValue: "AudioInterruptionBegan")
    // do not need to handle audioInterruptionEnded usually - instead listen for audioEngineReady!
    static let audioInterruptionEnded = NSNotification.Name(rawValue: "AudioInterruptionEnded")
}
