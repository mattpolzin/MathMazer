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
    let state = state ?? AppState()

    switch state.tool {
    case .mapMaker:
        return cellGridMapMakerReducer(action: action, state: state)
    case .mazeMaker:
        // TODO: mazeMakerReducer
        return state
    }
}

func cellGridMapMakerReducer(action: Action, state: AppState) -> AppState {
    var state = state

    if let cellAction = action as? CellAction {
        let cell = state.cells[cellAction.position.row][cellAction.position.column]

        state.cells[cellAction.position.row][cellAction.position.column] = cellMapMakerReducer(action: cellAction, cell: cell)
    }

    state = excludedCellCountReducer(state: state)

    return state
}

func cellMapMakerReducer(action: CellAction, cell: Cell) -> Cell {
    var cell = cell

    switch action {
    case is Cell.TappedAction:
        guard cell.cellType.hasNoLines else {
            return cell
        }
        cell.cellType.toggle()
        return cell

    default:
        return cell
    }
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
                let rowCount = rowCountSinceLastExcludedCell > 0 ? rowCount : nil
                let columnCount = columnCountsSinceLastExcludedCell[columnIdx] > 0 ? columnCounts[columnIdx] : nil
                state.cells[rowIdx][columnIdx].cellType = .excluded(
                    dotCount: DotCount(toTheRight: rowCount, below: columnCount)
                )
                // finding an excluded cell resets the counts
                resetAllCounts()
            case .included(design: let designLines, play: _):
                if !designLines.isEmpty {
                    columnCounts[columnIdx] += 1
                    rowCount += 1
                }
                columnCountsSinceLastExcludedCell[columnIdx] += 1
                rowCountSinceLastExcludedCell += 1
            }
        }
    }

//    print(state.cells.map { $0.map { ($0.dotCount) } })

    return state
}
