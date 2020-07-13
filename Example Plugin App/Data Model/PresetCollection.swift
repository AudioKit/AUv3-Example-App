//
//  PresetCollection.swift
//  AU Example App
//
//  Created by Jeff Cooper on 5/9/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation
import UIKit

protocol PresetCollection: Codable {
    var name: String { get set }
    var presets: [InstrumentPreset] { get }
}

extension PresetCollection {

    var presetIDs: [String] {
        return presets.map( {$0.uid })
    }
    
    var dictionary: [String: Any]? {
      guard let data = try? JSONEncoder().encode(self) else { return nil }
      return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }

    func indexOf(preset: InstrumentPreset) -> Int? {
        return presets.firstIndex(where: {$0.uid == preset.uid })
    }
    
    func contains(preset: InstrumentPreset) -> Bool {
        return presetIDs.contains(where: { $0 == preset.uid })
    }

    func contains(presetName: String) -> Bool {
        return presets.map({ $0.name }).contains(where: { $0 == presetName })
    }
}
