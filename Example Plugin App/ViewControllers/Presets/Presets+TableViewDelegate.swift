//
//  Presets+TableViewDelegate.swift
//  AU Example App
//
//  Created by Jeff Cooper on 5/11/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension PresetsController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.view.endEditing(true)

        if tableView == banksTableView {

            guard
                let cell = banksTableView.cellForRow(at: indexPath) as? PresetCollectionCell,
                let collection = cell.collection
            else {
                return
            }

            //update the selected collection
            updateVisibleCollection(collection: collection)

        } else if tableView == self.presetsTableView {

            let presetID = visiblePresetCollection?.presetIDs[indexPath.row]
            //load preset if not already selected
            guard
                let preset = presetsList.presets.first(where: { $0.uid == presetID })
            else {
                return
            }
            if presetFromConductor?.uid != preset.uid {
                conductor?.loadPreset(preset)
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == banksTableView {
            guard
                indexPath.row < presetsList.sortedBanks.count,
                let bank = presetsList.sortedBanks[indexPath.row] as? PresetBank,
                bank.uuid != presetsList.favoritesBank.uuid
                else { return false }
            return true
        } else {
            return true
        }
    }

    // Editing the table view.
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView,
                                                                          commit editingStyle: UITableViewCell.EditingStyle,
                                                                          forRowAt indexPath: IndexPath) {

        let index = indexPath.row

        if editingStyle == .delete {
            if tableView == banksTableView {
                guard presetsList.sortedBanks.count > index else { return }

                // Get cell
                guard
                    let cell = tableView.cellForRow(at: indexPath) as? PresetCollectionCell,
                    let bankToDelete = cell.collection as? PresetBank
                    else { return }
                presetsList.deleteBank(bank: bankToDelete)
                reloadCollectionsTable()
                reloadPresetsTable()
            } else {
                guard
                    let visibleCollection = visiblePresetCollection,
                    visibleCollection.presets.count > index
                    else { return }

                // Get cell
                guard
                    let cell = tableView.cellForRow(at: indexPath) as? PresetCell,
                    let presetToDelete = cell.preset
                    else { return }
                presetsList.deletePresetFromAllBanks(presetToDelete)
                reloadPresetsTable()
            }
        }
    }

    @objc(tableView:canFocusRowAtIndexPath:) func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support rearranging the table view.
    @objc(tableView:moveRowAtIndexPath:toIndexPath:) func tableView(_ tableView: UITableView,
                                                                    moveRowAt fromIndexPath: IndexPath,
                                                                    to toIndexPath: IndexPath) {

        let moveFromIndex = fromIndexPath.row
        let moveToIndex = toIndexPath.row

        guard
            let visibleCollection = visiblePresetCollection,
            moveToIndex < visibleCollection.presets.count,
            moveFromIndex < visibleCollection.presets.count
        else {
            return
        }

        guard var bank = visiblePresetCollection as? PresetBank else { return }
        bank.movePreset(from: moveFromIndex, to: moveToIndex)
        bank.saveToDisk()
        presetsList.loadLists()
    }

    // Override to support conditional rearranging of the table view.
    @objc(tableView:canMoveRowAtIndexPath:) func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // Change default icon (hamburger) for moving cells in UITableView
      func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
          let imageView = cell.subviews.first(where: { $0.description.contains("Reorder") })?.subviews.first(where: { $0 is UIImageView }) as? UIImageView

          imageView?.image = UIImage(named: "hamburger")
          imageView?.contentMode = .center

          imageView?.frame.size.width = cell.bounds.height
          imageView?.frame.size.height = cell.bounds.height
      }
}
