//
//  Presets+Callbacks.swift
//  AU Example App
//
//  Created by Matthew Fecher on 2/5/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import MobileCoreServices
import UIKit

extension PresetsController {

    // **********************************************************
    // MARK: - Callbacks
    // **********************************************************

    func setupCallbacks() {

        importButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            let documentPicker = UIDocumentPickerViewController(documentTypes: [(kUTTypeText as String)], in: .import)
            documentPicker.delegate = strongSelf
            strongSelf.present(documentPicker, animated: true, completion: nil)
        }

        newPresetButton.callback = { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.createAndSaveNewPreset()
        }

        newBankButton.callback = { [weak self] value in
            guard let strongSelf = self else { return }
            let newBank = strongSelf.presetsList.addNewBank(addNewPreset: true)
            self?.updateVisibleCollection(collection: newBank)
       }

        reorderButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.presetsTableView.isEditing.toggle()
            strongSelf.presetsTableView.reloadData()
            strongSelf.setReorderButton(isEditing: strongSelf.presetsTableView.isEditing)
        }

        doneEditingButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.view.endEditing(true)
            // save preset
            guard var currentPreset = strongSelf.presetFromConductor else { return }
            let oldPreset = currentPreset
            currentPreset.infoText = strongSelf.presetDescriptionField.text
            strongSelf.presetsList.overwritePreset(oldPreset: oldPreset, newPreset: currentPreset)
        }

        cancelEditingButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.view.endEditing(true)
            strongSelf.presetDescriptionField.text = strongSelf.presetFromConductor?.infoText ?? "Text here"
        }
    }

    func setReorderButton(isEditing: Bool) {
        if isEditing {
            reorderButton.setTitle("I'M DONE!", for: UIControl.State())
            reorderButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            reorderButton.backgroundColor = UIColor(red: 230/255, green: 136/255, blue: 2/255, alpha: 1.0)
        } else {
            reorderButton.setTitle("Reorder", for: UIControl.State())
            reorderButton.setTitleColor(#colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1), for: .normal)
            reorderButton.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.1764705882, blue: 0.1764705882, alpha: 1)
            reloadPresetsTable()
        }
    }

    private func createAndSaveNewPreset() {
        var initPreset = InstrumentPreset(name: presetsList.getSafePresetName(name: PresetConstants.initPresetName))
        initPreset.isUser = true //fixme : make activeBank be new userbank if no bank exists
        conductor?.loadPreset(initPreset)
        var bankToAddNewPresetTo = presetsList.userBanks.first(where: { $0.name == visiblePresetCollection?.name }) ??
            presetsList.userBanks.first(where: { $0.name == PresetConstants.userBankDefaultName }) ??
            PresetBank(name: PresetConstants.userBankDefaultName, midiBankChangeNumber: UInt8(presetsList.userBanks.count))
        bankToAddNewPresetTo.add(preset: initPreset)
        bankToAddNewPresetTo.saveToDisk()
        presetsList.addOrOverwrite(bank: bankToAddNewPresetTo)
        updateVisibleCollection(collection: bankToAddNewPresetTo)
    }
}


extension PresetsController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {

        let fileName = String(describing: url.lastPathComponent)

        // Check if it is a bank or single preset
        if fileName.hasSuffix(PresetConstants.presetBankSuffix) {
            guard let importedBank = presetsList.importBank(url: url) else { return }
            updateVisibleCollection(collection: importedBank)
        }

        if fileName.hasSuffix(PresetConstants.presetsSuffix) {
            let bankToImportTo: PresetBank
            //visible collection is a bank, and is NOT the favorites bank, it's ok to import to
            if let visibleBank = visiblePresetCollection as? PresetBank,
                visibleBank.name != presetsList.favoritesBank.name {
                bankToImportTo = visibleBank
            } else {
                bankToImportTo = presetsList.getNewOrExistingBank(name: PresetConstants.importBankDefaultName)
            }
            guard let importedPreset = presetsList.importPreset(url: url, to: bankToImportTo) else { return }
            conductor?.loadPreset(importedPreset)
            setToActiveBank()
            reloadCollectionsTable()
            reloadPresetsTable()
        }
    }
}
