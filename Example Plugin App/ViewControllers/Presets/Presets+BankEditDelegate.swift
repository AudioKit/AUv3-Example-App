//
//  Presets+BankEditDelegate.swift
//  AU Example App
//
//  Created by Matthew Fecher on 5/12/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

extension PresetsController: BankPopOverDelegate {
    func didFinishEditing(bank: PresetBank, newName: String) {
        let oldName = bank.name
        let renamedBank = presetsList.renameBank(bank: bank, newName: newName)
        deboog("did rename bank \(oldName) to \(renamedBank.name)")
        reloadCollectionsTable()
    }
}
