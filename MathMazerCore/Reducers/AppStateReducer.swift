//
//  AppStateReducer.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/5/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation
import ReSwift
import AppKit

public func cellGridReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    if let controlBarAction = action as? ControlBarAction {
        state = controlBarReducer(action: controlBarAction, state: state)
    }

    state = cellGridMapMakerReducer(action: action, state: state)

    if let keyDownAction = action as? CellModel.KeyDownAction {
        state = keyDownCellReducer(action: keyDownAction, state: state)
    }

    state = excludedCellCountReducer(state: state)

    return state
}

func cellGridMapMakerReducer(action: Action, state: AppState) -> AppState {
    var state = state

    if let cellAction = action as? CellAction {
        let oldCell = state.cells[cellAction.position.row][cellAction.position.column]
        let newCell = cellMapMakerReducer(action: cellAction, cell: oldCell, mode: state.tool.mode)

        state.cells[cellAction.position.row][cellAction.position.column] = newCell

        // if the cell has a special mark, select it. If not, deselect it
        let currentCell = state.cell(at: cellAction.position)
        let mode = state.tool.mode
        if (currentCell.specialMark != nil && currentCell.specialMark != .blank) || !currentCell.hasNoLines(in: mode) {
            if action is CellModel.TappedAction {
                state.selectedCellPosition = cellAction.position
            }
        } else if mode != .design,
            state.selectedCellPosition == cellAction.position,
            !(action is KeyboardAction) {
                state.selectedCellPosition = nil
        }
    }

    return state
}

func keyDownCellReducer(action: CellModel.KeyDownAction, state: AppState) -> AppState {
    guard let selectedPosition = state.selectedCellPosition else {
        return state
    }

    var state = state

    let oldPosition = selectedPosition
    let newPosition: GridPosition
    switch action.key {
    case .rightArrow:
        newPosition = selectedPosition.toTheRight(limitedBy: state.columns - 1)
    case .leftArrow:
        newPosition = selectedPosition.toTheLeft()
    case .upArrow:
        newPosition = selectedPosition.above()
    case .downArrow:
        newPosition = selectedPosition.below(limitedBy: state.rows - 1)
    }

    guard oldPosition != newPosition,
        case .included(let oldIncluded) = state.cell(at: oldPosition).cellType,
        case .included(let newIncluded) = state.cell(at: newPosition).cellType,
        (state.tool.mode == .design || newIncluded.specialMark != .blank) else {
        return state
    }

    guard let originIncludedDesignLines = state.tool.mode == .design
        ? oldIncluded.designLines.union(Lines.inDirection(of: action.key))
        : oldIncluded.designLines else {
            return state
    }

    guard let originIncludedPlayLines = state.tool.mode == .play
        ? oldIncluded.playLines.union(Lines.inDirection(of: action.key))
        : oldIncluded.playLines else {
            return state
    }

    guard let destinationIncludedDesignLines = state.tool.mode == .design
        ? newIncluded.designLines.union(Lines.away(from: action.key))
        : newIncluded.designLines else {
            return state
    }

    guard let destinationIncludedPlayLines = state.tool.mode == .play
        ? newIncluded.playLines.union(Lines.away(from: action.key))
        : newIncluded.playLines else {
            return state
    }

    state.selectedCellPosition = newPosition

    state.cells[oldPosition.row][oldPosition.column].cellType = .included(
        .init(
            designLines: originIncludedDesignLines,
            playLines: originIncludedPlayLines,
            specialMark: oldIncluded.specialMark
        )
    )

    state.cells[newPosition.row][newPosition.column].cellType = .included(
        .init(
            designLines: destinationIncludedDesignLines,
            playLines: destinationIncludedPlayLines,
            specialMark: newIncluded.specialMark
                ?? (state.tool.mode == .play ? .dot : nil)
        )
    )

    return state
}

func cellMapMakerReducer(action: CellAction, cell: CellState, mode: Mode) -> CellState {
    var cell = cell

    switch action {
    case is CellModel.TappedAction where mode == .design:
        guard cell.hasNoLines && cell.specialMark == nil else {
            break
        }
        cell.cellType.toggle()

    case is CellModel.TappedAction where mode == .play:
        guard case .included(let included) = cell.cellType,
            included.specialMark == nil else {
                break
        }
        cell.cellType = .included(included.togglingDot())

    case is CellModel.CtrlClickedAction:
        guard case .included(let included) = cell.cellType else {
            break
        }
        // delete lines (and special mark if there are no lines)
        cell.cellType = .included(
            .init(
                designLines: mode == .design ? .noLines : included.designLines,
                playLines: mode == .play ? .noLines : included.playLines,
                specialMark: cell.hasNoLines(in: mode) && (mode == .design || cell.specialMark == .dot)
                    ? nil
                    : included.specialMark
            )
        )

    case is CellModel.ShiftClickedAction where mode == .design:
        guard case .included(let included) = cell.cellType else {
            return cell
        }
        // set a marker or toggle between them
        cell.cellType = .included(included.togglingMarkForDesign())

    case is CellModel.ShiftClickedAction where mode == .play:
        guard case .included(let included) = cell.cellType else {
            return cell
        }
        // set a marker or toggle between them
        cell.cellType = .included(included.togglingBlank())

    case let dragAction as CellModel.DraggingAction:
        guard case .included(let included) = cell.cellType,
            var lines = Lines.between(dragAction.startClosestSide, dragAction.endClosestSide).flatMap(LegalLines.init) else {
            break
        }

        lines = cell.specialMark.flatMap { specialMark in
            switch specialMark {
            case .start:
                return dragAction.endClosestSide.line
            case .end:
                return dragAction.startClosestSide.line
            default:
                return nil
            }
        }.flatMap(LegalLines.init) ?? lines

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
                if included.designLines != .noLines {
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
