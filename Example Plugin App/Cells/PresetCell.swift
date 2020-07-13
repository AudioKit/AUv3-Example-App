//
//  PresetCell.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 7/28/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

protocol PresetCellDelegate: AnyObject {
    func editPressed()
    func duplicatePressed()
    func sharePressed()
    func favoritePressed()
}

class PresetCell: UITableViewCell {

    @IBOutlet weak var presetNameLabel: UILabel!
    @IBOutlet weak var renameButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var duplicateButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var cellButtons: UIView!

    weak var delegate: PresetCellDelegate?
    var preset: InstrumentPreset?
    var mainBankName = "Bank A"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        // set cell selection color
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView  = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = duplicateButton?.backgroundColor
        super.setSelected(selected, animated: animated)

        duplicateButton?.backgroundColor = color
        renameButton?.backgroundColor = color
        shareButton?.backgroundColor = color

        // Configure the view for the selected state
        presetNameLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // Overwritten in storyboard, highlighted color
        backgroundColor = selected ? #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.262745098, alpha: 1) : #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0)
        cellButtons?.isHidden = !selected
    }

    func configureCell(preset: InstrumentPreset, programChangeNumber: UInt8? = nil, bankNumber: UInt8? = nil,
                       isFavorite: Bool = false) {
        self.preset = preset
        var bankPositionText = ""
        var positionText = ""
        if let programChangeNumber = programChangeNumber {
            positionText = "\(programChangeNumber): "
        }
        if let bankNumber = bankNumber {
            bankPositionText = "\(bankNumber) ▸ " //optional - add +1 here
        }
        presetNameLabel.text = bankPositionText + positionText + "\(preset.name)"

        if isFavorite {
            favoriteButton?.setImage(UIImage(named: "ak_favfilled"), for: .normal)
        } else {
            favoriteButton?.setImage(UIImage(named: "ak_fav"), for: .normal)
        }
    }

    @IBAction func duplicatePressed(_ sender: UIButton) {
        delegate?.duplicatePressed()
    }

    @IBAction func editPressed(_ sender: UIButton) {
        delegate?.editPressed()
    }

    @IBAction func sharePressed(_ sender: UIButton) {
        delegate?.sharePressed()
    }

    @IBAction func favoritePressed(_ sender: UIButton) {
        delegate?.favoritePressed()
    }
}
