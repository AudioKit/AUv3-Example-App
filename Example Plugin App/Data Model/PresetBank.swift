//
//  PresetBank.swift
//  AU Example App
//
//  Created by Jeff Cooper on 5/9/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

struct PresetBank: PresetCollection {
    var uuid: UUID = UUID()
    var name: String
    var presets: [InstrumentPreset]
    var midiBankChangeNumber: UInt8?
    var bankChangeDisplay: String? {
        if let bankNumber = midiBankChangeNumber {
            return String(bankNumber + 0) // optional add +1 here
        }
        return nil
    }
    var canDelete: Bool = true

    var pathOnDisk: String {
        return PresetBank.pathFor(name: name)
    }

    var filename: String {
        return PresetBank.filenameFor(name: name)
    }

    init(name: String, presets: [InstrumentPreset] = [InstrumentPreset](),
         midiBankChangeNumber: UInt8? = nil, canDelete: Bool = true) {
        self.name = name
        self.presets = presets
        self.midiBankChangeNumber = midiBankChangeNumber
    }

    init?(dictionary: [String: Any]) {
        guard
            let name = dictionary["name"] as? String,
            let presetDicts = dictionary["presets"] as? [[String : Any]],
            let canDelete = dictionary["canDelete"] as? Bool
            else { return nil }

        let midiBankChangeNumber = dictionary["midiBankChangeNumber"] as? UInt8
        var decodedPresets = [InstrumentPreset]()
        for presetDict in presetDicts {
            let decodedPreset = InstrumentPreset(dictionary: presetDict)
            decodedPresets.append(decodedPreset)
        }
        self.init(name: name, presets: decodedPresets, midiBankChangeNumber: midiBankChangeNumber, canDelete: canDelete)
    }

    init?(data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dictionary = json as? [String: Any]  {
            self.init(dictionary: dictionary)
            return
        }
        return nil
    }

    mutating func generateNewUUID() {
        self.uuid = UUID()
    }

    @discardableResult mutating func add(preset: InstrumentPreset) -> Bool {
        guard !contains(preset: preset) else { return false }
        presets.append(preset)
        return true
    }

    @discardableResult mutating func insert(preset: InstrumentPreset, at position: Int) -> Bool {
        guard !contains(preset: preset) else { return false }
        presets.insert(preset, at: position)
        return true
    }

    @discardableResult mutating func remove(preset: InstrumentPreset) -> Bool {
        guard let index = indexOf(preset: preset) else { return false }
        presets.remove(at: index)
        return true
    }

    @discardableResult mutating func replacePreset(oldPreset: InstrumentPreset, newPreset: InstrumentPreset) -> Bool {
        guard let index = indexOf(preset: oldPreset) else { return false }
        presets.replaceSubrange(Range(index...index), with: [newPreset])
        return true
    }

    @discardableResult mutating func movePreset(from: Int, to: Int) -> Bool {
        guard from < presets.count, to < presets.count else { return false }
        let toPreset = presets[to]
        let movingPreset = presets[from]
        presets.replaceSubrange(Range(to...to), with: [movingPreset])
        presets.replaceSubrange(Range(from...from), with: [toPreset])
        return true
    }

    @discardableResult mutating func duplicatePreset(preset: InstrumentPreset) -> InstrumentPreset? {
        guard let index = indexOf(preset: preset), var copy = preset.copy() else { return nil }
        copy.name = preset.name.getSafeName(comparingTo: presets.map({ $0.name }))
        insert(preset: copy, at: index + 1)
        return copy
    }

    func duplicate(newName: String? = nil) -> PresetBank {
        let newName = newName ?? name + " copy"
        return PresetBank(name: newName, presets: presets, midiBankChangeNumber: midiBankChangeNumber)
    }

    @discardableResult func saveToDisk() -> Bool {
        return DiskManager().save(presetBank: self)
    }

    @discardableResult func deleteFromDisk() -> Bool {
        return DiskManager().deleteFile(path: pathOnDisk)
    }

    static func pathFor(name: String) -> String {
        return PresetConstants.presetBanksFolder + "/" + PresetBank.filenameFor(name: name)
    }

    static func filenameFor(name: String) -> String {
        return name + "." + PresetConstants.presetBankSuffix
    }

}
