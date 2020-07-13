//
//  Presets+TextView.swift
//  AU Example App
//
//  Created by Matthew Fecher on 2/5/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit

extension PresetsController: UITextViewDelegate {

    // MARK: - Text Field View

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        cancelEditingButton.isHidden = false
        doneEditingButton.isHidden = false

        newPresetButton.isHidden = true
        newBankButton.isHidden = true
        reorderButton.isHidden = true
        importButton.isHidden = true

    }

    func textViewDidEndEditing(_ textView: UITextView) {
        doneEditingButton.isHidden = true
        cancelEditingButton.isHidden = true
        newPresetButton.isHidden = false
        newBankButton.isHidden = false
        reorderButton.isHidden = false
        importButton.isHidden = false
    }
}
