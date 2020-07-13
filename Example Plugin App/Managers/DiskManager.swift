//
//  DiskManager.swift
//  Vinyl Piano
//
//  Created by Jeff Cooper on 5/5/20.
//  Copyright © 2020 Vinyl Piano. All rights reserved.
//

import Disk
import Foundation

class DiskManager {

    var directory: Disk.Directory {
        return .sharedContainer(appGroupName: FileConstants.sharedContainer)
    }

    func exists(relativePath: String) -> Bool {
        return Disk.exists(relativePath, in: directory)
    }

    func saveTemporaryPreset(preset: InstrumentPreset) -> URL? {
        let presetLocation = "temp/\(preset.filename)"
        try? Disk.save(preset, to: .caches, as: presetLocation)
        guard let url = try? Disk.url(for: presetLocation, in: .caches) else {
            deboog("Save temporary preset failed - no file found at \(presetLocation)")
            return nil
        }
        return url
    }

    func saveTemporaryBank(bank: PresetBank) -> URL? {
        let bankLocation = "temp/\(bank.filename)"
        try? Disk.save(bank, to: .caches, as: bankLocation)
        guard let url = try? Disk.url(for: bankLocation, in: .caches) else {
            deboog("Save temporary bank failed - no file found at \(bankLocation)")
            return nil
        }
        return url
    }

    @discardableResult func removeFile(url: URL) -> Bool {
        do {
            try Disk.remove(url)
        } catch {
            deboog("error removing \(url.path): \(error)")
            return false
        }
        return true
    }

    func removeFile(path: String) {
        do { try Disk.remove(path, from: directory) }
        catch {  deboog("error removing \(path): \(error)") }
    }

    @discardableResult func save(presetBank: PresetBank) -> Bool {
        do {
            try Disk.save(presetBank, to: directory, as: presetBank.pathOnDisk)
        } catch {
            deboog("error saving preset \(presetBank.name): \(error)")
            return false
        }
        return true
    }

    func get(presetBankName: String) -> PresetBank? {
        do {
            let presetBank = try Disk.retrieve(PresetBank.pathFor(name: presetBankName),
                                               from: directory, as: PresetBank.self)
            return presetBank
        } catch {
            deboog("error retrieving preset \(presetBankName): \(error)")
            return nil
        }
    }

    func get(presetBankPath: String) -> PresetBank? {
        do {
            let presetBank = try Disk.retrieve(presetBankPath,
                                               from: directory, as: PresetBank.self)
            return presetBank
        } catch {
            deboog("error retrieving preset path \(presetBankPath): \(error)")
            return nil
        }
    }

    func getFilesNames(inDirectory subdir: String) -> [String]? {
        guard let path = FileConstants.appGroupPath else { return nil }
        let subPath = path + "/"  + subdir
        return FileManager.default.subpaths(atPath: subPath)
    }

    func getAllPresetBanks() -> [PresetBank]? {
        guard let presetBankFiles = getFilesNames(inDirectory: PresetConstants.presetBanksFolder) else { return nil }
        var banks = [PresetBank]()
        for file in presetBankFiles {
            if let preset = try? Disk.retrieve(PresetConstants.presetBanksFolder + "/" + file,
                                               from: directory, as: PresetBank.self) {
                banks.append(preset)
            }
        }
        return banks.count > 0 ? banks : nil
    }

    /* the following much simpler function fails with "The file “PresetLists” couldn’t be opened because you don’t have permission to view it."
    func getAllPresetBanks() -> [PresetBank]? {
        do {
            let presetBanks = try Disk.retrieve(AudioConstants.presetListsFolder,
                                               from: directory, as: [PresetBank].self)
            return presetBanks
        } catch {
            deboog("error retrieving presetBanks from  \(AudioConstants.presetListsFolder): \(error)")
            return nil
        }
    }
    */

    func getAllPresets() -> [InstrumentPreset]? {
        guard let presetFileNames = getFilesNames(inDirectory: PresetConstants.presetsFolder) else { return nil }
        var presets = [InstrumentPreset]()
        for file in presetFileNames {
            if let preset = try? Disk.retrieve(PresetConstants.presetsFolder + "/" + file,
                                               from: directory, as: InstrumentPreset.self) {
                presets.append(preset)
            }
        }
        return presets.count > 0 ? presets : nil
    }

    func save(preset: InstrumentPreset) {
        let path = (PresetConstants.presetsFolder + "/" + preset.name + "."
            + PresetConstants.presetsSuffix).trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            var presetToSave = preset
            presetToSave.pathOnDisk = path
            try Disk.save(presetToSave, to: directory, as: path)
        } catch {
            deboog("error saving preset \(preset.name): \(error)")
        }
    }

    func remove(preset: InstrumentPreset) {
        remove(presetName: preset.name)
    }

    func remove(presetName: String) {
        let path = (PresetConstants.presetsFolder + "/" + presetName + "." + PresetConstants.presetsSuffix).trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try Disk.remove(path, from: directory)
        } catch {
            deboog("error removing preset \(presetName): \(error)")
        }
    }

    func deleteAllPresets() {
        deleteFile(path: PresetConstants.presetsFolder)
    }

    func deleteAllPresetBanks() {
        deleteFile(path: PresetConstants.presetBanksFolder)
    }

    @discardableResult func deleteURL(url: URL) -> Bool {
        do  {
            try Disk.remove(url)
        } catch {
            deboog("error removing all presets at \(url.path) : \(error)")
            return false
        }
        return true
    }

    @discardableResult func deleteFile(path: String) -> Bool {
        let fileManager = FileManager.default
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: FileConstants.sharedContainer) {
            do {
                try fileManager.removeItem(atPath: directory.path + "/" + path)
                return true
            } catch {
                deboog("error removing all presets at \(path) : \(error)")
                return false
            }
        }
        return false
    }
}
