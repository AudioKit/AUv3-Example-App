//
//  Parent+MIDI.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/28/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

extension ParentController: AKMIDIListener {

    // Assign MIDI CC to active MIDI Learn knobs
    func assignMIDIControlToKnobs(cc: MIDIByte) {
        let activeMIDILearnKnobs = midiKnobs.filter { $0.isActive }
        activeMIDILearnKnobs.forEach {
            $0.parameter?.midiControllers = [cc]
            $0.isActive = false
        }
    }

    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil, offset: MIDITimeStamp = 0) {
        guard let conductor = conductor, channel == conductor.midiChannelIn || conductor.omniMode else { return }

        // MIDI LEARN: If any MIDI Learn knobs are active, assign the CC
         DispatchQueue.main.async { [weak self] in //isSelected must be called from main thread
            guard let strongSelf = self else { return }
            if strongSelf.midiLearnButton.isSelected { strongSelf.assignMIDIControlToKnobs(cc: controller) }
        }

    }

}
