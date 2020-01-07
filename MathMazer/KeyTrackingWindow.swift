//
//  KeyTrackingWindow.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/6/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation
import AppKit
import ReSwift

class KeyTrackingWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
        guard event.type == .keyDown,
            let action = KeyDownAction(for: event) else {
            return
        }

        store.dispatch(action)
    }
}

struct KeyDownAction: Action {
    let key: Key

    init?(for event: NSEvent) {
        guard let specialKey = event.specialKey else {
            return nil
        }
        switch specialKey {
        case .leftArrow:
            key = .leftArrow
        case .rightArrow:
            key = .rightArrow
        case .upArrow:
            key = .upArrow
        case .downArrow:
            key = .downArrow

        default:
            return nil
        }
    }

    enum Key {
        case leftArrow
        case rightArrow
        case upArrow
        case downArrow
    }
}

struct KeyDownInCellAction: CellAction {
    let position: Cell.Position
    let key: KeyDownAction.Key
}
