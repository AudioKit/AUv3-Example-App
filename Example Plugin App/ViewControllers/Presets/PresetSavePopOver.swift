//
//  PresetSavePopOver.swift
//  AU Example App
//
//  Created by Matthew Fecher on 2/4/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit

protocol PresetPopOverDelegate: AnyObject {
    func didFinishEditing(name: String, isEditing: Bool)
}

class PresetSavePopOver: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var saveButton: PresetUIButton!
    @IBOutlet weak var cancelButton: PresetUIButton!

    var isEditingPreset = false
    weak var delegate: PresetPopOverDelegate?
    var presetName: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        popupView.layer.borderColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        popupView.layer.borderWidth = 4
        popupView.layer.cornerRadius = 6

        nameTextField.text = presetName

        setupCallbacks()
    }

    // MARK: - IBActions

    func setupCallbacks() {

        cancelButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true, completion: nil)
        }

        saveButton.callback = { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.didFinishEditing(name: strongSelf.nameTextField.text ?? "Unnamed", isEditing: strongSelf.isEditingPreset)
            strongSelf.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UITextFieldDelegate

extension PresetSavePopOver: UITextFieldDelegate {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
}
