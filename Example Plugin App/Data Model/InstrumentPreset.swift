//
//  RhodesPreset.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/29/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

struct InstrumentPreset: Codable {

    var uid = UUID().uuidString
    var name: String
    var position = 0 // Preset # in the list
    var infoText = "Your Preset"
    var modWheelDestination: ModwheelDestination = .vibrato
    var isUser = false
    var bankNumber = 0
    var programChangeNumber = 0
    var pathOnDisk: String?
    private var version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown version"
    private var originalUid: String

    var parameterValues = [ParameterValuePair]() //use parameterValue.identifier for saving AUValues

    var filename: String {
        return InstrumentPreset.filenameFor(name: name)
    }
    
    init(name: String) {
        self.name = name
        originalUid = uid
    }

    init(conductor: Conductor, name: String, infoText: String = "Your Preset", bankNumber: Int = 0, programChangeNumber: Int = 0) {
        self.init(name: name)
        self.infoText = infoText
        self.bankNumber = bankNumber
        self.programChangeNumber = programChangeNumber
        setValuesFromConductor(conductor)
    }

    mutating func generateNewUID() {
        uid = UUID().uuidString
    }

    private mutating func setValuesFromConductor(_ conductor: Conductor) {
        parameterValues.removeAll()
        for param in conductor.allParameters { //set values based on params from conductor
            parameterValues.append(ParameterValuePair(identifier: param.identifier, value: param.value))
        }
        modWheelDestination = conductor.modwheelDest
    }

    func getValueForParam(param: ExampleInstrumentParameter) -> Float {
        return parameterValues.first(where: {$0.identifier == param.identifier})?.value ?? param.baseParameter.defaultValue
    }

    func matches(conductor: Conductor?) -> Bool {
        guard let conductor = conductor else { return true }
        for param in conductor.allParameterControls {
            if param.value != getValueForParam(param: param) {
                return false
            }
        }
        return true
    }

    var dictionary: [String: Any]? {
      guard let data = try? JSONEncoder().encode(self) else { return nil }
      return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }

    func copy() -> InstrumentPreset? {
        guard let dict = dictionary else { return nil }
        return InstrumentPreset(dictionary: dict, newUID: true)
    }

    //*****************************************************************
    // MARK: - JSON Parsing into object
    //*****************************************************************

    init(dictionary: [String: Any], newUID: Bool = false) {
        if let originalUID = dictionary["uid"] as? String, newUID == false {
            self.originalUid = originalUID
        } else {
            self.originalUid = UUID().uuidString
        }
        self.uid = self.originalUid
        self.name = dictionary["name"] as? String ?? "PresetFromDictionary"
        self.position = dictionary["position"] as? Int ?? position
        self.infoText = dictionary["infoText"] as? String ?? infoText
        self.modWheelDestination = ModwheelDestination(rawValue: dictionary["modWheelDestination"] as! Int) ?? modWheelDestination
        self.isUser = dictionary["isUser"] as? Bool ?? isUser
        self.bankNumber = dictionary["bankNumber"] as? Int ?? bankNumber
        self.programChangeNumber = dictionary["programChangeNumber"] as? Int ?? programChangeNumber
        self.version = dictionary["version"] as? String ?? version
        self.pathOnDisk = dictionary["pathOnDisk"] as? String

        if let paramDictionary = dictionary["parameterValues"] as? [[String: Any]] {
            for params in paramDictionary {
                    parameterValues.append(ParameterValuePair(identifier: params["identifier"] as? String ?? "",
                                                              value: params["value"] as? Float ?? 0.0))
            }
        }
    }

    init?(data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dictionary = json as? [String: Any]  {
            self.init(dictionary: dictionary)
            return
        }
        return nil
    }

    //*****************************************************************
    // MARK: - Class Function to Return array of Presets
    //*****************************************************************

    // Return Array of Presets
    static public func parseDataToPresets(jsonArray: [Any]) -> [InstrumentPreset] {
        var presets = [InstrumentPreset]()
        for presetJSON in jsonArray {
            if let presetDictionary = presetJSON as? [String: Any] {
                let retrievedPreset = InstrumentPreset(dictionary: presetDictionary)
                presets.append(retrievedPreset)
            }
        }
        return presets
    }

    // Return Single Preset
    static public func parseDataToPreset(presetJSON: Any) -> InstrumentPreset? {
        if let presetDictionary = presetJSON as? [String: Any] {
            return InstrumentPreset(dictionary: presetDictionary)
        }
        return nil
    }

    func saveToDisk() {
        DiskManager().save(preset: self)
    }

    static func pathFor(name: String) -> String {
        return PresetConstants.presetsFolder + "/" + InstrumentPreset.filenameFor(name: name)
    }

    static func filenameFor(name: String) -> String {
        return name + "." + PresetConstants.presetsSuffix
    }
}
