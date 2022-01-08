//
//  ControlBarModel+Actions.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/5/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation
import ReSwift

protocol ControlBarAction: Action {}

extension ControlBarModel {
    struct TappedPlayToggle: ControlBarAction { fileprivate init() {} }
    struct TappedReset: ControlBarAction { fileprivate init() {} }
    struct TappedSave: ControlBarAction { fileprivate init() {} }
    struct TappedOpen: ControlBarAction { fileprivate init() {} }
    struct ChoseFilename: ControlBarAction {
        let file: URL
        let purpose: Purpose

        fileprivate init(file: URL, purpose: Purpose) {
            self.file = file
            self.purpose = purpose
        }

        enum Purpose {
            case save
            case open
        }
    }

    static let tappedPlayToggle = TappedPlayToggle()
    static let tappedReset = TappedReset()
    static let tappedSave = TappedSave()
    static let tappedOpen = TappedOpen()

    static func chose(file: URL, for purpose: ChoseFilename.Purpose) -> ChoseFilename {
        return ChoseFilename(file: file, purpose: purpose)
    }
}
