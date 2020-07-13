//
//  AppDelegate.swift
//  AU Example Code
//
//  Created by Jeff Cooper on 1/7/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Never Sleep mode is false
        UIApplication.shared.isIdleTimerDisabled = false

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

}
