//
//  ControlBar+Actions.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/5/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation
import ReSwift

extension ControlBar {
    struct TappedPlayToggle: Action {}
    struct TappedSave: Action {}
    struct TappedOpen: Action {}
    struct ChoseFilename: Action {
        let file: URL
        let purpose: Purpose

        enum Purpose {
            case save
            case open
        }
    }

    static let tappedPlayToggle = TappedPlayToggle()
    static let tappedSave = TappedSave()
    static let tappedOpen = TappedOpen()

    static func chose(file: URL, for purpose: ChoseFilename.Purpose) -> ChoseFilename {
        return ChoseFilename(file: file, purpose: purpose)
    }
}
