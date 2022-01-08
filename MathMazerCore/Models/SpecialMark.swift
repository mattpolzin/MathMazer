//
//  SpecialMark.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/9/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation

enum SpecialMark: String, Codable, Hashable {
    case start
    case end
    case dot
    case blank

    var toggledForDesign: SpecialMark {
        switch self {
        case .start:
            return .end
        case .end:
            return .start
        case .dot, .blank:
            return .start
        }
    }
}
