//
//  ParameterController.swift
//  AU Example App
//
//  Created by Jeff Cooper on 2/10/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

protocol ParameterController: class {
    var parameter: ExampleInstrumentParameter? { get set }
    var callback: (Double) -> Void { get set }
}
