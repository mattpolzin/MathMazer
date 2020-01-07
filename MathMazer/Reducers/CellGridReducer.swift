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

    state = cellGridMapMakerReducer(action: action, state: state)

    // TODO: rename to Cell.KeyDownAction
    if let keyDownAction = action as? KeyDownInCellAction {
        state = keyDownCellReducer(action: keyDownAction, state: state)
    }

    return state
}

func cellGridMapMakerReducer(action: Action, state: AppState) -> AppState {
    var state = state

    if let cellAction = action as? CellAction {
        let oldCell = state.cells[cellAction.position.row][cellAction.position.column]
        let newCell = cellMapMakerReducer(action: cellAction, cell: oldCell, mode: state.tool.mode)

        state.cells[cellAction.position.row][cellAction.position.column] = newCell

        // if the cell has a special mark, select it.
        if state.cell(at: cellAction.position).specialMark != nil && action is Cell.TappedAction {
            state.selectedCellPosition = cellAction.position
        }
    }

    state = excludedCellCountReducer(state: state)

    return state
}

func keyDownCellReducer(action: KeyDownInCellAction, state: AppState) -> AppState {
    guard let selectedPosition = state.selectedCellPosition else {
        return state
    }

    var state = state

    let oldPosition = selectedPosition
    let newPosition: Cell.Position
    switch action.key {
    case .rightArrow:
        state.selectedCellPosition = selectedPosition.toTheRight(limitedBy: state.columns)
    case .leftArrow:
        state.selectedCellPosition = selectedPosition.toTheLeft()
    case .upArrow:
        state.selectedCellPosition = selectedPosition.above()
    case .downArrow:
        state.selectedCellPosition = selectedPosition.below(limitedBy: state.rows)
    }
    newPosition = state.selectedCellPosition!

    guard case .included(let oldIncluded) = state.cell(at: oldPosition).cellType else {
        return state
    }

    let oldIncludedDesignLines = state.tool.mode == .design
        ? oldIncluded.designLines.union(Lines.inDirection(of: action.key))
        : oldIncluded.designLines

    let oldIncludedPlayLines = state.tool.mode == .play
        ? oldIncluded.playLines.union(Lines.inDirection(of: action.key))
        : oldIncluded.playLines

    state.cells[oldPosition.row][oldPosition.column].cellType = .included(
        .init(
            designLines: oldIncludedDesignLines,
            playLines: oldIncludedPlayLines,
            specialMark: oldIncluded.specialMark
        )
    )

    guard oldPosition != newPosition,
        case .included(let newIncluded) = state.cell(at: newPosition).cellType else {
            return state
    }

    let newIncludedDesignLines = state.tool.mode == .design
        ? newIncluded.designLines.union(Lines.away(from: action.key))
        : newIncluded.designLines

    let newIncludedPlayLines = state.tool.mode == .play
        ? newIncluded.playLines.union(Lines.away(from: action.key))
        : newIncluded.playLines

    state.cells[newPosition.row][newPosition.column].cellType = .included(
        .init(
            designLines: newIncludedDesignLines,
            playLines: newIncludedPlayLines,
            specialMark: newIncluded.specialMark
        )
    )

    return state
}

func cellMapMakerReducer(action: CellAction, cell: Cell, mode: Mode) -> Cell {
    var cell = cell

    switch action {
    case is Cell.TappedAction where mode == .design:
        guard cell.hasNoLines && cell.specialMark == nil else {
            break
        }
        cell.cellType.toggle()

    case is Cell.CtrlClickedAction:
        guard case .included(let included) = cell.cellType else {
            break
        }
        // delete lines (and special mark in design mode)
        cell.cellType = .included(
            .init(
                designLines: mode == .design ? [] : included.designLines,
                playLines: mode == .play ? [] : included.playLines,
                specialMark: mode == .design ? nil : included.specialMark
            )
        )

    case is Cell.ShiftClickedAction where mode == .design:
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
            break
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
                designLines: mode == .design ? lines : included.designLines,
                playLines: mode == .play ? lines : included.playLines,
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
