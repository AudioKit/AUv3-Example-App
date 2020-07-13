//
//  ModuloOperator.swift
//  AU Example App
//
//  Created by Jeff Cooper on 2/7/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import Foundation

infix operator %%

extension Int {
    static  func %% (_ left: Int, _ right: Int) -> Int {
        if left >= 0 { return left % right }
        if left >= -right { return (left+right) }
        return ((left % right)+right)%right
    }
}
