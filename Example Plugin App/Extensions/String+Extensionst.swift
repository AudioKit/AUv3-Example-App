//
//  String+CapitalizeFirst.swift
//  DigitalD1
//
//  Created by Matthew Fecher on 10/6/18.
//  Copyright © 2018 AudioKit Pro. All rights reserved.
//

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension String {

    // send this an array of strings to compare to, and it will spit out a new unique string
    // with no other arguments, it adds a counter to the original string
    // with 'addingText' parameter, it will keep appending 'addText' until name is unique (copy copy copy)
    func getSafeName(comparingTo existingNames: [String],
                             addingText addText: String? = nil) -> String {
        var newName = self
        var baseName = self
        var counter = 1
        let nameComponents = self.split(separator: " ")
        if nameComponents.count > 1,
            let lastComponent = nameComponents.last,
            let suffixCounter = Int(String(lastComponent)) {
            baseName = nameComponents.dropLast().joined(separator: " ")
            counter = suffixCounter
        }
        while existingNames.contains(where: {$0 == newName}) {
            if let addText = addText {
                newName = newName + addText
            } else {
                newName = baseName + " \(counter)"
            }
            counter += 1
        }
        return newName
    }
}
