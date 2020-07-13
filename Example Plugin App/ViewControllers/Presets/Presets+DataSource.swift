//
//  Presets+DataSource.swift
//  AU Example App
//
//  Created by Jeff Cooper on 5/11/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit

// *****************************************************************
// MARK: - TableViewDataSource
// *****************************************************************

extension PresetsController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 44
        } else {
            return 32
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == banksTableView {
            return presetsList.sortedBanks.count
        } else {
            return visiblePresetCount
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let index = indexPath.row

        if tableView == banksTableView {
            guard
                index < presetsList.sortedBanks.count,
                let cell = tableView.dequeueReusableCell(withIdentifier: "PresetCollectionCell") as? PresetCollectionCell
            else {
                return PresetCollectionCell()
            }

            let presetCollection = presetsList.sortedBanks[index]
            let bankText: String? = (presetCollection as? PresetBank)?.bankChangeDisplay
            cell.configureCell(collection: presetCollection, bankText: bankText)
            cell.delegate = self
            return cell

        } else {
            guard
                index < visiblePresetCount,
                let collection = visiblePresetCollection,
                let cell = tableView.dequeueReusableCell(withIdentifier: "PresetCell") as? PresetCell,
                let preset = presetsList.presets.first(where: { $0.uid == collection.presets[index].uid })
            else {
                return PresetCell()
            }

            let isFavorite = presetsList.favoritesBank.contains(preset: preset)

            let isPresetBank = visiblePresetCollection is PresetBank

            // show position in bank if this is not an auto-generated list
            let position: UInt8? = isPresetBank ? UInt8(index) : presetsList.getMIDIProgramNumber(preset: preset)

            //show bank position if selected collection is auto-generated
            let bankNumber: UInt8? = isPresetBank ? nil : presetsList.getMIDIBankChangeNumber(for: preset)

            cell.configureCell(preset: preset, programChangeNumber: position,
                               bankNumber: bankNumber, isFavorite: isFavorite)
            cell.delegate = self
            return cell
        }
    }
}
