//
//  PresetsController.swift
//  AU Example App
//
//  Created by Matthew Fecher on 1/31/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit

class PresetsController: UIViewController {
    
    @IBOutlet weak var presetsTableView: UITableView!
    @IBOutlet weak var banksTableView: UITableView!
    @IBOutlet weak var importButton: SynthUIButton!
    @IBOutlet weak var reorderButton: SynthUIButton!
    @IBOutlet weak var doneEditingButton: PresetUIButton!
    @IBOutlet weak var cancelEditingButton: PresetUIButton!
    @IBOutlet weak var newPresetButton: PresetUIButton!
    @IBOutlet weak var presetDescriptionField: UITextView!
    @IBOutlet weak var newBankButton: PresetUIButton!
    
    var conductor: Conductor?
    
    var presetFromConductor: InstrumentPreset? {
        return conductor?.currentPreset
    }
    var presetsList = PresetsManager.shared

    private var visibleCollectionName: String?
    private var visibleBankID: UUID? //only for Banks - not collections
    private var visiblePresetIDs: [String]? { return visiblePresetCollection?.presetIDs }
    var visiblePresetCount: Int { return visiblePresetIDs?.count ?? 0}
    var visiblePresetCollection: PresetCollection? {
        return presetsList.sortedBanks.first(where: {$0.name == visibleCollectionName})
    }
    var delegate: PresetsControllerDelegate?
    
    private var isVisible: Bool {
        return viewIfLoaded?.window != nil
    }
    
    private func updateDisplay(preset: InstrumentPreset?) {
        guard let preset = preset else { return }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presetDescriptionField.text = preset.infoText
        }
    }
    
    // **********************************************************
    // MARK: - LifeCycle
    // **********************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Preset Description TextField
        presetDescriptionField.delegate = self
        presetDescriptionField.layer.cornerRadius = 3
        
        // set color for lines between rows
        presetsTableView.separatorColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.3882352941, alpha: 1)

        if let firstBank = presetsList.userBanks.first {
            updateVisibleCollection(collection: firstBank)
        }

        setupCallbacks()

        banksTableView.delegate = self
        banksTableView.dataSource = self
        banksTableView.layer.cornerRadius = 3
        banksTableView.layer.borderWidth = 1
        presetsTableView.delegate = self
        presetsTableView.dataSource = self
        presetsTableView.layer.cornerRadius = 3
        presetsTableView.layer.borderWidth = 1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        LocalNotificationCenter.sharedInstance.center.addObserver(self,
                                                                  selector: #selector(presetLoadedNotification(_:)),
                                                                  name: .PresetLoaded, object: nil)
        reloadCollectionsTable()
        reloadPresetsTable()
        updateDisplay(preset: presetFromConductor)
        updateReorderButton()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LocalNotificationCenter.sharedInstance.center.removeObserver(self)
    }

    func updateVisibleCollection(collection: PresetCollection) {
        visibleBankID = nil
        visibleCollectionName = collection.name
        if let bank = collection as? PresetBank {
            visibleBankID = bank.uuid
        }
        reloadCollectionsTable()
        reloadPresetsTable()
        updateReorderButton()
    }

    // this sets the collection view to a user-editable bank if they try to edit while in an auto-generated collection
    // example: in alphabetical view, and 'duplicate' is pressed
    @discardableResult func setToActiveBank() -> PresetBank {
        var activeBank: PresetBank
        if let visibleBank = presetsList.userBanks.first(where: { $0.uuid == visibleBankID}),
            visibleBank.name != presetsList.favoritesBank.name {
            activeBank = visibleBank
        } else if let currentPreset = presetFromConductor,
            let existingBank = presetsList.getBankFor(preset: currentPreset) {
            activeBank = existingBank
        } else {
            activeBank = presetsList.getNewOrExistingBank(name: PresetConstants.userBankDefaultName)
        }

        updateVisibleCollection(collection: activeBank)
        return activeBank
    }

    // this selects the current collection in the collection table view - uses name, but we could lock that down better
    func selectCurrentBankTableRow() {
        // Find the bank in the current view
        if let index = presetsList.sortedBanks.firstIndex(where: { $0.name == visibleCollectionName }) {
            let indexPath = IndexPath(row: index, section: 0)
            DispatchQueue.main.async { [weak self] in
                if self?.banksTableView.validate(indexPath: indexPath) ?? false {
                    self?.banksTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                }
            }
        } else {
            presetsTableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }

    // this selects the current preset in the presets table view - uses uuid
    func selectCurrentPresetTableRow() {
        // Find the preset in the current view
        if let index = visiblePresetIDs?.firstIndex(where: { $0 == presetFromConductor?.uid }) {
            let indexPath = IndexPath(row: index, section: 0)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                if strongSelf.presetsTableView.validate(indexPath: indexPath) {
                    strongSelf.presetsTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                }
            }
        } else {
            presetsTableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }

    // **********************************************************
    // MARK: - Preset Loading/Saving Functions
    // **********************************************************

    @objc private func presetLoadedNotification(_ notification: Notification) {
        guard conductor?.exampleInstrument.uid == notification.object as? String else { return }
        if let dict = notification.userInfo as? [String : Any],
            let preset = dict["preset"] as? InstrumentPreset {
            updateDisplay(preset: preset)
            selectCurrentBankTableRow()
            selectCurrentPresetTableRow()
        }
    }

    private func selectPresetBy(listPosition: Int = 0) {
        guard
            listPosition < visiblePresetCount,
            let preset = visiblePresetCollection?.presets[listPosition]
            else {
                return
        }
        conductor?.loadPreset(preset)
    }

    func nextPreset() {
        guard visiblePresetCount > 0 else { return }
        var index = visiblePresetCollection?.presetIDs.firstIndex(where: { $0 == presetFromConductor?.uid }) ?? -1
        index = (index + 1) %% visiblePresetCount
        selectPresetBy(listPosition: index)
    }

    func prevPreset() {
        guard visiblePresetCount > 0 else { return }
        var index = visiblePresetCollection?.presetIDs.firstIndex(where: { $0 == presetFromConductor?.uid }) ?? 0
        index = (index - 1) %% visiblePresetCount
        selectPresetBy(listPosition: index)
    }

    func saveIconPressed() {
        self.performSegue(withIdentifier: "SegueToSave", sender: self)
    }

    func reloadCollectionsTable() {
        presetsList.loadLists()
        banksTableView.reloadData()
        selectCurrentBankTableRow()
    }

    func reloadPresetsTable() {
        presetsList.loadLists()
        presetsTableView.reloadData()
        selectCurrentPresetTableRow()
    }

    func updateReorderButton() {
        reorderButton.isEnabled = visiblePresetCollection is PresetBank
        reorderButton.alpha = visiblePresetCollection is PresetBank ? 1 : 0.333
    }

    // **********************************************************
    // MARK: - Segues
    // **********************************************************

    // MARK: - This has to not be in this file and not in an extension
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "SegueToSave" {
            guard let popOverController = segue.destination as? PresetSavePopOver else { return }
            popOverController.delegate = self
            popOverController.presetName = presetFromConductor?.name ?? "New Preset"
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 0)
            }
        }

        if segue.identifier == "SegueToEdit" {
            guard let popOverController = segue.destination as? PresetSavePopOver,
                let currentPreset = presetFromConductor else { return }
            popOverController.delegate = self
            popOverController.isEditingPreset = true
            popOverController.presetName = currentPreset.name
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 0)
            }
        }

        if segue.identifier == "SegueToBankEdit" {
            guard let popOverController = segue.destination as? BankEditorPopOver else { return }
            popOverController.delegate = self
            if let bankToRename = visiblePresetCollection as? PresetBank {
                popOverController.bank = bankToRename
            }

            popOverController.preferredContentSize = CGSize(width: 300, height: 320)
            if let presentation = popOverController.popoverPresentationController {
                presentation.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            }
        }
    }

    func showSharePopup(withFile url: URL, completion: @escaping ((URL) -> Void)) {
        // Share
        let activityViewController = UIActivityViewController( activityItems: [url], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
            }
            // User completed activity
            completion(url)
        }

        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
}

protocol PresetsControllerDelegate {
    func selectBank(_ bank: PresetCollection, presetController: PresetsController)
}
