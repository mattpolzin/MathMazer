//
//  Side.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/9/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation

enum Side: String, Codable, Hashable {
    case left
    case right
    case top
    case bottom

    var line: Lines {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }
}
