//
//  ChildView.swift
//  AU Example App
//
//  Created by Matthew Fecher on 1/14/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

public enum ChildView: Int {
    case mainView = 0
    case presetsView
    case moreView
    case aboutView

    static let maxValue = 1

    func identifier() -> String {
        switch self {
        case .mainView: return "MainController"
        case .presetsView: return "PresetsController"
        case .moreView: return "MoreController"
        case .aboutView: return "AboutController"
        }
    }
}
