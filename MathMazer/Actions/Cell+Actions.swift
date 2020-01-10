//
//  Cell+Actions.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/5/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation
import ReSwift

protocol CellAction: Action {
    var position: Cell.Position { get }
}

extension Cell {
    struct TappedAction: CellAction {
        let position: Position

        fileprivate init(position: Position) {
            self.position = position
        }
    }

    struct CtrlClickedAction: CellAction {
        let position: Position

        fileprivate init(position: Position) {
            self.position = position
        }
    }

    struct ShiftClickedAction: CellAction {
        let position: Position

        fileprivate init(position: Position) {
            self.position = position
        }
    }

    struct DraggingAction: CellAction {
        let position: Position
        let startClosestSide: Side
        let endClosestSide: Side

        fileprivate init(position: Position, startClosestSide: Side, endClosestSide: Side) {
            self.position = position
            self.startClosestSide = startClosestSide
            self.endClosestSide = endClosestSide
        }
    }

    struct KeyDownAction: CellAction {
        let position: Cell.Position
        let key: MathMazer.KeyDownAction.Key
    }

    var tapped: TappedAction {
        TappedAction(position: self.position)
    }

    var ctrlClicked: CtrlClickedAction {
        CtrlClickedAction(position: self.position)
    }

    var shiftClicked: ShiftClickedAction {
        ShiftClickedAction(position: self.position)
    }

    func dragging(from side1: Side, to side2: Side) -> DraggingAction {
        DraggingAction(position: self.position, startClosestSide: side1, endClosestSide: side2)
    }
}
