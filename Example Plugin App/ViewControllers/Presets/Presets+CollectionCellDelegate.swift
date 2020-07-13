//
//  PresetCollectionCellDelegate.swift
//  AU Example App
//
//  Created by Jeff Cooper on 4/30/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit

extension PresetsController: PresetCollectionCellDelegate {

    func sharePresetCollection(collectionCell: PresetCollectionCell) {
        guard let bankToShare = visiblePresetCollection as? PresetBank else { return }
        guard let url = DiskManager().saveTemporaryBank(bank: bankToShare) else {
            deboog("Share bank failed")
            return
        }
        showSharePopup(withFile: url, completion: { url in
            DiskManager().deleteURL(url: url)
        })
    }

    func editPresetCollection(collectionCell: PresetCollectionCell) {
        deboog("bankEdit \(collectionCell.collection?.name ?? "no name in collection") - use presetsList.renameBank(bank)")
        performSegue(withIdentifier: "SegueToBankEdit", sender: self)
    }
}
