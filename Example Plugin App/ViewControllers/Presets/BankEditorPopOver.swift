//
//  BankEditorPopOver.swift
//  AU Example App
//
//  Created by Matthew Fecher on 4/29/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//


import UIKit

protocol BankPopOverDelegate: AnyObject {
    func didFinishEditing(bank: PresetBank, newName: String)
}

class BankEditorPopOver: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var cancelButton: PresetUIButton!
    @IBOutlet weak var saveButton: PresetUIButton!
    @IBOutlet weak var deleteButton: PresetUIButton!

    weak var delegate: BankPopOverDelegate?

    var bank: PresetBank?

    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        popupView.layer.borderWidth = 2
        popupView.layer.cornerRadius = 6

        nameTextField.text = bank?.name ?? "no bank set for popover"

        setupCallbacks()
    }

    func setupCallbacks() {

        cancelButton.callback = { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }

        saveButton.callback = { [weak self] _ in
            guard let bank = self?.bank else { return }
            self?.delegate?.didFinishEditing(bank: bank, newName: self?.nameTextField.text ?? "Unnamed")
            self?.dismiss(animated: true, completion: nil)
        }

    }

}
