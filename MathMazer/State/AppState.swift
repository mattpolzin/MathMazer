//
//  AppState.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/5/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import ReSwift
import Foundation

struct AppState: StateType {
    var cells: [[Cell]]

    var selectedCellPosition: Cell.Position?

    var tool: Tool

    var controlBar: ControlBar {
        ControlBar(buildMode: tool.mode)
    }
}

extension AppState {

    init(width: Int = 10, height: Int = 10) {
        precondition(width > 0)
        precondition(height > 0)

        cells = (0..<height).map { row in
            (0..<width).map { column in
                let cellType: Cell.CellType
                if row > 0
                    && column > 0
                    && row < height - 1
                    && column < width - 1 {
                    cellType = .included(design: [], play: [], specialMark: nil)
                } else {
                    cellType = .excluded
                }

                return Cell(row: row, column: column, cellType: cellType)
            }
        }

        tool = .mapMaker

        selectedCellPosition = nil
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
                .init(row: 2, column: 1, cellType: .included(design: [], play: [], specialMark: nil)),
                .init(row: 2, column: 2, cellType: .included(design: .lowerRight, play: [], specialMark: nil)),
                .init(row: 2, column: 3, cellType: .included(design: .lowerLeft, play: [], specialMark: nil)),
                .init(row: 2, column: 4, cellType: .excluded)
            ],
            [
                .init(row: 3, column: 0, cellType: .included(design: .horizontal, play: [], specialMark: nil)),
                .init(row: 3, column: 1, cellType: .included(design: .lowerLeft, play: [], specialMark: nil)),
                .init(row: 3, column: 2, cellType: .included(design: .vertical, play: [], specialMark: nil)),
                .init(row: 3, column: 3, cellType: .included(design: .upperRight, play: [], specialMark: nil)),
                .init(row: 3, column: 4, cellType: .included(design: .horizontal, play: [], specialMark: nil))
            ],
            [
                .init(row: 4, column: 0, cellType: .excluded),
                .init(row: 4, column: 1, cellType: .included(design: .upperRight, play: [], specialMark: nil)),
                .init(row: 4, column: 2, cellType: .included(design: .upperLeft, play: [], specialMark: nil)),
                .init(row: 4, column: 3, cellType: .included(design: [], play: [], specialMark: nil)),
                .init(row: 4, column: 4, cellType: .excluded)
            ],
            [
                .init(row: 5, column: 0, cellType: .excluded),
                .init(row: 5, column: 1, cellType: .included(design: [], play: [], specialMark: nil)),
                .init(row: 5, column: 2, cellType: .included(design: [], play: [], specialMark: nil)),
                .init(row: 5, column: 3, cellType: .included(design: [], play: [], specialMark: nil)),
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
        tool: .mapMaker
    )
}
