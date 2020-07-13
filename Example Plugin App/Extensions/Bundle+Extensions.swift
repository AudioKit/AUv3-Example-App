//
//  Bundle+Extensions.swift
//  DigitalD1
//
//  Created by Matthew Fecher on 7/20/19.
//  Copyright © 2019 AudioKit Pro. All rights reserved.
//

import Foundation

extension Bundle {
    static func appName() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return ""
        }
        if let version : String = dictionary["CFBundleDisplayName"] as? String {
            return version
        } else {
            return ""
        }
    }
    
}

// Use it as follows:
// let appName = Bundle.appName()

// let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
