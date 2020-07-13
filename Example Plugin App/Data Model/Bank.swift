//
//  Bank.swift
//  AU Example App
//
//  Created by Matthew Fecher on 1/14/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

class Bank: Codable {
    var name = "BankA"
    var position = 0

    init() {}

    convenience init(name: String, position: Int) {
        self.init()
        self.name = name
        self.position = position
    }

    // Init from Dictionary/JSON
    init(dictionary: [String: Any]) {
        name = dictionary["name"] as? String ?? name
        position = dictionary["position"] as? Int ?? position
    }
}
