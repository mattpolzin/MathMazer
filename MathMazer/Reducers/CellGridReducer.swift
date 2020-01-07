//
//  CellGridReducer.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/5/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation
import ReSwift

func cellGridReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    // TODO: categorize all control bar actions and create a separate reducer for them
    switch action {
    case is ControlBar.TappedPlayToggle:
        state.tool.toggle()
    default:
        break
    }

    switch state.tool {
    case .mapMaker:
        return cellGridMapMakerReducer(action: action, state: state)
    case .player:
        // TODO: mazeMakerReducer
        return state
    }
}

func cellGridMapMakerReducer(action: Action, state: AppState) -> AppState {
    var state = state

    if let cellAction = action as? CellAction {
        let oldCell = state.cells[cellAction.position.row][cellAction.position.column]
        let newCell = cellMapMakerReducer(action: cellAction, cell: oldCell)

        state.cells[cellAction.position.row][cellAction.position.column] = newCell

        // if the cell did not change, select it
        if oldCell == newCell {
            state.selectedCellPosition = cellAction.position
        }
    }

    state = excludedCellCountReducer(state: state)

    return state
}

func cellMapMakerReducer(action: CellAction, cell: Cell) -> Cell {
    var cell = cell

    switch action {
    case is Cell.TappedAction:
        guard cell.hasNoLines && cell.specialMark == nil else {
            return cell
        }
        cell.cellType.toggle()

    case is Cell.CtrlClickedAction:
        guard case .included(let included) = cell.cellType else {
            return cell
        }
        // delete design lines and special mark but leave play lines
        cell.cellType = .included(.init(designLines: [], playLines: included.playLines, specialMark: nil))

    case is Cell.ShiftClickedAction:
        guard case .included(let included) = cell.cellType else {
            return cell
        }
        // set a marker or toggle between them
        cell.cellType = .included(
            .init(
                designLines: included.designLines,
                playLines: included.playLines,
                specialMark: included.specialMark?.toggled ?? .start
            )
        )

    case let dragAction as Cell.DraggingAction:
        guard case .included(let included) = cell.cellType,
            var lines = Lines.between(dragAction.startClosestSide, dragAction.endClosestSide) else {
            return cell
        }

        lines = cell.specialMark.map { specialMark in
            switch specialMark {
            case .start:
                return dragAction.endClosestSide.line
            case .end:
                return dragAction.startClosestSide.line
            }
        } ?? lines

        cell.cellType = .included(
            .init(
                designLines: lines,
                playLines: included.playLines,
                specialMark: included.specialMark
            )
        )

    default:
        break
    }

    return cell
}

func excludedCellCountReducer(state: AppState) -> AppState {
    var state = state

    // count backwards through rows and columns, keeping track of the
    // number of maze cells encountered since the last excluded cell.
    var columnCounts = Array(repeating: 0, count: state.cells[0].count)
    var columnCountsSinceLastExcludedCell = columnCounts
    for rowIdx in (0..<state.cells.count).reversed() {
        var rowCount = 0
        var rowCountSinceLastExcludedCell = rowCount
        for columnIdx in (0..<state.cells[rowIdx].count).reversed() {
            func resetAllCounts() {
                columnCounts[columnIdx] = 0
                rowCount = 0
                columnCountsSinceLastExcludedCell[columnIdx] = 0
                rowCountSinceLastExcludedCell = 0
            }

            switch state.cells[rowIdx][columnIdx].cellType {
            case .excluded:
                let rowCount = rowCountSinceLastExcludedCell > 0
                    ? rowCount
                    : nil
                let columnCount = columnCountsSinceLastExcludedCell[columnIdx] > 0
                    ? columnCounts[columnIdx]
                    : nil

                state.cells[rowIdx][columnIdx].cellType = .excluded(
                    dotCount: DotCount(toTheRight: rowCount, below: columnCount)
                )
                // finding an excluded cell resets the counts
                resetAllCounts()

            case .included(let included):
                if !included.designLines.isEmpty {
                    columnCounts[columnIdx] += 1
                    rowCount += 1
                }
                columnCountsSinceLastExcludedCell[columnIdx] += 1
                rowCountSinceLastExcludedCell += 1
            }
        }
    }

    return state
}
