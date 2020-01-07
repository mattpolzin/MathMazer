//
//  Tool.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/5/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation

enum Tool: String, Codable, Hashable {
    case mapMaker
    case player

    mutating func toggle() {
        switch self {
        case .mapMaker:
            self = .player

        case .player:
            self = .mapMaker
        }
    }

    var mode: Mode {
        switch self {
        case .mapMaker:
            return .design
        case .player:
            return .play
        }
    }
}

enum Mode: Hashable {
    case design
    case play
}
