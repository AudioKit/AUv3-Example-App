//
//  PresetCollectionCell.swift
//  AU Example App
//
//  Created by Jeff Cooper on 5/11/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//
import UIKit

protocol PresetCollectionCellDelegate: AnyObject {
    func sharePresetCollection(collectionCell: PresetCollectionCell)
    func editPresetCollection(collectionCell: PresetCollectionCell)
}

class PresetCollectionCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    private var canEdit: Bool { return collection is PresetBank && collection?.name != PresetConstants.favoritesBankDefaultName }
    private var canShare: Bool { return collection is PresetBank }
    var collection: PresetCollection?
    var bankText: String?

    weak var delegate: PresetCollectionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        // set cell selection color
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView  = selectedView

        nameLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        updateView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            nameLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            backgroundColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 1)
        } else {
             nameLabel?.textColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
             backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0)
        }
        updateView()
    }

    func configureCell(collection: PresetCollection, bankText: String? = nil) {
        self.collection = collection
        self.bankText = bankText
        updateView()
    }

    private func updateView() {
        var bankDisplayText = ""
        if let bankText = bankText {
            bankDisplayText = "\(bankText): "
        }
        nameLabel?.text = bankDisplayText + (collection?.name ?? "No collection defined in cell")
        editButton.isHidden = !(canEdit && isSelected)
        shareButton.isHidden = !(canShare && isSelected)
    }

    @IBAction func sharePressed(_ sender: UIButton) {
        delegate?.sharePresetCollection(collectionCell: self)
    }

    @IBAction func editPressed(_ sender: UIButton) {
        delegate?.editPresetCollection(collectionCell: self)
    }
}
