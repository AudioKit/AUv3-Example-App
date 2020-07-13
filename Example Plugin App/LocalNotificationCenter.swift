//
//  LocalNotificationCenter.swift
//  AU Example App
//
//  Created by Jeff Cooper on 1/19/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

class LocalNotificationCenter {
    static let sharedInstance = LocalNotificationCenter()
    var center = NotificationCenter()
}
