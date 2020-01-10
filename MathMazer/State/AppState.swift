//
//  AppState.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/5/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import ReSwift
import Foundation

struct AppState: StateType, Codable {
    var cells: [[CellState]]

    private(set) var cellSelections: CellSelections

    var selectedCellPosition: GridPosition? {
        get {
            switch tool.mode {
            case .design:
                return cellSelections.design
            case .play:
                return cellSelections.play
            }
        }
        set {
            switch tool.mode {
            case .design:
                cellSelections.design = newValue
            case .play:
                cellSelections.play = newValue
            }
        }
    }

    var tool: ToolState

    var controlBar: ControlBarModel {
        ControlBarModel(buildMode: tool.mode)
    }

    var rows: Int { cells.count }
    var columns: Int { cells[0].count }

    func cell(at position: GridPosition) -> CellState {
        precondition(position.row >= 0 && position.row < rows)
        precondition(position.column >= 0 && position.column < columns)

        return cells[position.row][position.column]
//        set {
//            precondition(position.row >= 0 && position.row < rows)
//            precondition(position.column >= 0 && position.column < columns)
//
//            cells[position.row][position.column] = newValue
//        }
    }

    func clearingPlayMode() -> AppState {
        return .init(
            cells: cells.map { row in
                row.map { cell in
                    cell
                        .clearingPlayLines
                        .clearingDots
                }
            },
            cellSelections: .init(design: cellSelections.design, play: nil),
            tool: tool
        )
    }

    struct CellSelections: Equatable, Codable {
        var design: GridPosition?
        var play: GridPosition?
    }
}

extension AppState {

    init(width: Int = 10, height: Int = 10) {
        precondition(width > 0)
        precondition(height > 0)

        cells = (0..<height).map { row in
            (0..<width).map { column in
                let cellType: CellState.CellType
                if row > 0
                    && column > 0
                    && row < height - 1
                    && column < width - 1 {
                    cellType = .included(design: .noLines, play: .noLines, specialMark: nil)
                } else {
                    cellType = .excluded
                }

                return CellState(row: row, column: column, cellType: cellType)
            }
        }

        tool = .mapMaker

        cellSelections = .init()
    }

    static let mock: Self = .init(
        cells: [
            [
                .init(row: 0, column: 0, cellType: .excluded),
                .init(row: 0, column: 1, cellType: .excluded),
                .init(row: 0, column: 2, cellType: .excluded),
                .init(row: 0, column: 3, cellType: .excluded),
                .init(row: 0, column: 4, cellType: .excluded)
            ],
            [
                .init(row: 1, column: 0, cellType: .excluded),
                .init(row: 1, column: 1, cellType: .excluded),
                .init(row: 1, column: 2, cellType: .excluded),
                .init(row: 1, column: 3, cellType: .excluded),
                .init(row: 1, column: 4, cellType: .excluded)
            ],
            [
                .init(row: 2, column: 0, cellType: .excluded),
                .init(row: 2, column: 1, cellType: .included(design: .noLines, play: .noLines, specialMark: nil)),
                .init(row: 2, column: 2, cellType: .included(design: .lowerRight, play: .noLines, specialMark: nil)),
                .init(row: 2, column: 3, cellType: .included(design: .lowerLeft, play: .noLines, specialMark: nil)),
                .init(row: 2, column: 4, cellType: .excluded)
            ],
            [
                .init(row: 3, column: 0, cellType: .included(design: .horizontal, play: .noLines, specialMark: nil)),
                .init(row: 3, column: 1, cellType: .included(design: .lowerLeft, play: .noLines, specialMark: nil)),
                .init(row: 3, column: 2, cellType: .included(design: .vertical, play: .noLines, specialMark: nil)),
                .init(row: 3, column: 3, cellType: .included(design: .upperRight, play: .noLines, specialMark: nil)),
                .init(row: 3, column: 4, cellType: .included(design: .horizontal, play: .noLines, specialMark: nil))
            ],
            [
                .init(row: 4, column: 0, cellType: .excluded),
                .init(row: 4, column: 1, cellType: .included(design: .upperRight, play: .noLines, specialMark: nil)),
                .init(row: 4, column: 2, cellType: .included(design: .upperLeft, play: .noLines, specialMark: nil)),
                .init(row: 4, column: 3, cellType: .included(design: .noLines, play: .noLines, specialMark: nil)),
                .init(row: 4, column: 4, cellType: .excluded)
            ],
            [
                .init(row: 5, column: 0, cellType: .excluded),
                .init(row: 5, column: 1, cellType: .included(design: .noLines, play: .noLines, specialMark: nil)),
                .init(row: 5, column: 2, cellType: .included(design: .noLines, play: .noLines, specialMark: nil)),
                .init(row: 5, column: 3, cellType: .included(design: .noLines, play: .noLines, specialMark: nil)),
                .init(row: 5, column: 4, cellType: .excluded)
            ],
            [
                .init(row: 6, column: 0, cellType: .excluded),
                .init(row: 6, column: 1, cellType: .excluded),
                .init(row: 6, column: 2, cellType: .excluded),
                .init(row: 6, column: 3, cellType: .excluded),
                .init(row: 6, column: 4, cellType: .excluded)
            ]
        ],
        cellSelections: .init(),
        tool: .mapMaker
    )
}
