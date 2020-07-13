//
//  PresetsList.swift
//  AU Example App
//
//  Created by Jeff Cooper on 2/7/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//
// This manages a pool of presets and preset banks and does automatic things like save to disk after edits.
// This class is useful because when saving presets + banks, some awareness of the other banks / presets
// is important to prevent things like overwriting banks that have the same name, etc.
//
// Also the 'Favorites' bank is unique in that it contains duplicates of presets from other banks, so this handles that

import Foundation

class PresetsManager: NSObject {

    static let shared = PresetsManager()

    var presets: [InstrumentPreset] { return userBanks.flatMap({ $0.presets }) }

    private var banksLoaded = [PresetBank]()

    var allPresetsSortedByBank: PresetCollection {
        return AutomaticPresetCollection(name: "All",
                                    presets: userBanks.flatMap({ $0.presets }),
                                    position: 0)
    }
    var alphabeticalPresets: PresetCollection {
        return AutomaticPresetCollection(name: "Alphabetical",
                                    presets: presets.sorted(by: { $0.name.lowercased() < $1.name.lowercased() }),
                                    position: 1)
    }

    //this is a user-editable bank of favorites
    var favoritesBank = PresetBank(name: PresetConstants.favoritesBankDefaultName, canDelete: false)

    //these are banks that cannot be deleted
    var persistentBanks: [PresetCollection] {
        return [allPresetsSortedByBank] + [alphabeticalPresets] + [favoritesBank]
    }

    //these are fully editable banks
    var userBanks: [PresetBank] {
        return banksLoaded.filter( {
            $0.name != favoritesBank.name })
            .sorted(by: { $0.midiBankChangeNumber ?? 0 < $1.midiBankChangeNumber ?? 0})
    }

    //this is all banks + collections
    var sortedBanks: [PresetCollection] {
        return persistentBanks + userBanks
    }

    override init() {
        super.init()
        loadLists()
    }

    func testNewBanks() {
        let preset = InstrumentPreset(name: "Test New Preset")
        let presetBank = PresetBank(name: "test Bank", presets: [preset])
        let _ = presetBank.saveToDisk()
        let _ = DiskManager().getAllPresetBanks()
        let _ = DiskManager().get(presetBankName: presetBank.name)

        let _ = loadPresetsFromDisk()
        let _ = loadPresetsFromBundle()

        deboog("ran preset bank tests")
    }

    func loadLists() {
        if DiskManager().exists(relativePath: PresetConstants.presetBanksFolder),
            let banksFromDisk = loadBanksFromDisk() {
            banksLoaded = banksFromDisk
        } else {
            resetFactoryBanks()
        }
        favoritesBank = banksLoaded.first(where: { $0.name == favoritesBank.name }) ?? favoritesBank
        reindexUserBanks()
    }

    private func resetFactoryBanks() {
        let banksFromBundle = loadBanksFromBundle() ?? [PresetBank]()
        banksFromBundle.forEach({ bank in
            bank.saveToDisk()
            addOrOverwrite(bank: bank)
        })
    }

    func addOrOverwrite(bank: PresetBank) {
        if let index = banksLoaded.firstIndex(where: { $0.uuid == bank.uuid }) {
            banksLoaded[index] = bank
        } else {
            banksLoaded.append(bank)
        }
    }

    private func generateFactoryBankFromBundle() -> PresetBank {
        let presets = loadPresetsFromBundle() ?? [InstrumentPreset]()
        let factoryBank = PresetBank(name: PresetConstants.factoryBankDefaultName, presets: presets,
                                     midiBankChangeNumber: 0, canDelete: false)
        return factoryBank
    }

    private func generateFactoryBanksFromBundle() -> [PresetBank] {
        let banks = loadBanksFromBundle()
        return banks ?? [PresetBank]()
    }

    private func reindexUserBanks() {
        for bank in userBanks {
            guard let position = userBanks.firstIndex(where: { $0.uuid == bank.uuid}) else {
                break
            }
            var editBank = bank
            editBank.midiBankChangeNumber = UInt8(position)
            editBank.saveToDisk()
        }
    }

    private func removeAllBanks() {
        DiskManager().deleteAllPresetBanks()
    }

    private func loadPresetsFromDisk() -> [InstrumentPreset]? {
        let presets = DiskManager().getAllPresets()
        return presets
    }

    private func loadBanksFromDisk() -> [PresetBank]? {
        let banks = DiskManager().getAllPresetBanks() // don't return directly, because this operation takes time
        return banks
    }

    // this looks in the Assets catalog + PresetBanksFolder and returns all presets found there as json
    private func loadBanksFromBundle() -> [PresetBank]? {
        guard let bundle = Bundle(identifier: FileConstants.assetsID) else { return nil }
        var banks = [PresetBank]()
        let bankPaths = bundle.paths(forResourcesOfType: PresetConstants.presetBankSuffix, inDirectory: PresetConstants.presetBanksFolder)
        for bankPath in bankPaths {
            if let data = try? NSData(contentsOfFile: bankPath, options: .uncached) as Data,
                let bank = PresetBank(data: data) {
                banks.append(bank)
            }
        }
        return banks
    }

    // this looks in the Assets catalog + PresetsFolder and returns all presets found there as json
    private func loadPresetsFromBundle() -> [InstrumentPreset]? {
        guard let bundle = Bundle(identifier: FileConstants.assetsID) else { return nil }
        var presets = [InstrumentPreset]()
        let presetsPaths = bundle.paths(forResourcesOfType: PresetConstants.presetsSuffix,
                                        inDirectory: PresetConstants.presetsFolder)
        for path in presetsPaths {
            if let data = try? NSData(contentsOfFile: path, options: .uncached) as Data,
                let preset = InstrumentPreset(data: data) {
                presets.append(preset)
            }
        }
        return presets.sorted(by: { $0.position < $1.position })
    }

    func deletePresetFromAllBanks(_ preset: InstrumentPreset) {
        var banksContainingPreset = getAllBanksContaining(preset: preset)
        for item in banksContainingPreset.enumerated() {
            deboog("deleting preset \(preset.name) from bank \(item.element.name)")
            banksContainingPreset[item.offset].remove(preset: preset)
            banksContainingPreset[item.offset].saveToDisk()
        }
        loadLists()
    }

    func getNewOrExistingBank(name: String) -> PresetBank {
        return userBanks.first(where: { $0.name == name }) ?? addNewBank(name: name, addNewPreset: false)
    }

    @discardableResult func renamePreset(_ preset: InstrumentPreset, newName: String) -> String? {
        var nameSaved: String?
        let safeName = getSafePresetName(name: newName)
        for bank in getAllBanksContaining(preset: preset)  {
            deboog("renaming preset \(preset.name) in bank \(bank.name) to \(safeName)")
            var bankCopy = userBanks.first(where: { $0.uuid == bank.uuid })
            guard var presetToRename = bank.presets.first(where: {$0.uid == preset.uid}) else { break }
            presetToRename.name = safeName
            bankCopy?.replacePreset(oldPreset: preset, newPreset: presetToRename)
            bankCopy?.saveToDisk()
            nameSaved = safeName
        }
        loadLists()
        return nameSaved
    }

    @discardableResult func overwritePreset(oldPreset: InstrumentPreset, newPreset: InstrumentPreset) -> Bool {
        var didReplace = false
        for bank in getAllBanksContaining(preset: oldPreset) {
            deboog("overwriting preset \(oldPreset.name) in bank \(bank.name)")
            var bankCopy = userBanks.first(where: { $0.uuid == bank.uuid })
            bankCopy?.replacePreset(oldPreset: oldPreset, newPreset: newPreset)
            bankCopy?.saveToDisk()
            didReplace = true
        }
        loadLists() //fixme - do the above functions modify the actual presets in memory, or are they transient?
        return didReplace
    }

    @discardableResult func toggleFavorite(preset: InstrumentPreset) -> Bool {
        var isFavorite: Bool = false
        if favoritesBank.contains(preset: preset) {
            favoritesBank.remove(preset: preset)
            favoritesBank.saveToDisk()
            isFavorite = false
        } else {
            favoritesBank.add(preset: preset)
            favoritesBank.saveToDisk()
            isFavorite = true
        }
        loadLists()
        return isFavorite
    }

    func addNewBank(name: String = PresetConstants.userBankDefaultName, addNewPreset: Bool = false) -> PresetBank {
        let bankName = getSafeBankName(name: name)
        let initPreset = addNewPreset ? [InstrumentPreset(name: bankName + " \(PresetConstants.initPresetName)")] : [InstrumentPreset]()
        let newBank = PresetBank(name: bankName, presets: initPreset,
                                 midiBankChangeNumber: UInt8(userBanks.count))
        newBank.saveToDisk()
        loadLists()
        return newBank
    }

    func renameBank(bank: PresetBank, newName: String) -> PresetBank {
        var updatedBank = bank //create copy
        updatedBank.name = getSafeBankName(name: newName)
        updatedBank.saveToDisk()
        bank.deleteFromDisk()
        loadLists()
        return updatedBank
    }

    func deleteBank(bank: PresetBank) {
        let bankPresets = bank.presets
        bankPresets.forEach({ favoritesBank.remove(preset: $0) })
        favoritesBank.saveToDisk()
        bank.deleteFromDisk()
        loadLists()
    }

    func getBankFor(preset: InstrumentPreset) -> PresetBank? {
        return userBanks.first(where: { $0.presetIDs.contains(preset.uid) })
    }

    func getPresetVia(position: Int) -> InstrumentPreset? {
        return presets.first(where: {$0.position == position}) //FIXME - takws bank too
    }

    func getPresetViaPC(position: Int) -> InstrumentPreset? {
        let index = position %% presets.count
        return presets.first(where: {$0.position == index}) //FIXME - takws bank too
    }

    func getAllBanksContaining(preset: InstrumentPreset) -> [PresetBank] {
        return banksLoaded.filter({ $0.contains(preset: preset) })
    }

    // this returns the preset position in it's original bank - useful when displaying presets from multiple banks
    func getMIDIProgramNumber(preset: InstrumentPreset) -> UInt8? {
        if let existingPosition = getBankFor(preset: preset)?.indexOf(preset: preset) {
            return UInt8(existingPosition)
        }
        return nil
    }

    // this returns the position of the bank this preset belongs to
    func getMIDIBankChangeNumber(for preset: InstrumentPreset) -> UInt8? {
        if let bank = userBanks.first(where: {$0.contains(preset: preset)}) {
            return bank.midiBankChangeNumber
        }
        return nil
    }

    func getPreset(named name: String) -> InstrumentPreset? {
        return presets.first(where: { $0.name == name })
    }

    func getSafePresetName(name: String) -> String {
        return name.getSafeName(comparingTo: presets.map({ $0.name }))
    }

    func getSafeBankName(name: String) -> String {
        return name.getSafeName(comparingTo: sortedBanks.map({ $0.name }))
    }

    // File Imports
    func importPreset(url: URL, to bank: PresetBank) -> InstrumentPreset? {
        var updatedBank = bank //create a copy to edit
        guard let data = try? Data(contentsOf: url),
            var presetToImport = InstrumentPreset(data: data) else {
            deboog("importPreset URL Data failed: \(url)")
            return nil
        }
        presetToImport.generateNewUID()
        presetToImport.name = getSafePresetName(name: presetToImport.name)
        updatedBank.add(preset: presetToImport)
        updatedBank.saveToDisk()
        loadLists()
        return presetToImport
    }

    func importBank(url: URL) -> PresetBank? {
        guard let data = try? Data(contentsOf: url),
            var bankToImport = PresetBank(data: data) else {
                deboog("importBank URL Data failed: \(url)")
                return nil
        }
        bankToImport.name = getSafeBankName(name: bankToImport.name)
        bankToImport.midiBankChangeNumber = UInt8(userBanks.count)
        bankToImport.presets.forEach( {
            var newPreset = $0
            newPreset.generateNewUID()
            bankToImport.replacePreset(oldPreset: $0, newPreset: newPreset)
        })
        bankToImport.saveToDisk()
        loadLists()
        return bankToImport
    }
}
