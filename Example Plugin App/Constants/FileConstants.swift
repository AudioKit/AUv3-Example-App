//
//  FileConstants.swift
//  AU Example App
//
//  Created by Jeff Cooper on 5/15/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

class FileConstants {
    static let soundsFolder = "Sounds/81z LoTine"
    static let sampleFolder = "\(soundsFolder)/samples"
    static let assetsID = "io.audiokit.ExampleApp-Assets"
    static let sharedContainer = "group.com.audiokit.testAppGroup"
    static let appGroupPath = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: FileConstants.sharedContainer)?.path
}
