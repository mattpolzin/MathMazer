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

    var tool: Tool
}

extension AppState {
    init() {
        cells = (0..<10).map { row in
            (0..<10).map { column in
                Cell(row: row, column: column)
            }
        }

        tool = .mapMaker
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
                .init(row: 2, column: 1, cellType: .included(design: [], play: [])),
                .init(row: 2, column: 2, cellType: .included(design: .lowerRight, play: [])),
                .init(row: 2, column: 3, cellType: .included(design: .lowerLeft, play: [])),
                .init(row: 2, column: 4, cellType: .excluded)
            ],
            [
                .init(row: 3, column: 0, cellType: .included(design: .horizontal, play: [])),
                .init(row: 3, column: 1, cellType: .included(design: .lowerLeft, play: [])),
                .init(row: 3, column: 2, cellType: .included(design: .vertical, play: [])),
                .init(row: 3, column: 3, cellType: .included(design: .upperRight, play: [])),
                .init(row: 3, column: 4, cellType: .included(design: .horizontal, play: []))
            ],
            [
                .init(row: 4, column: 0, cellType: .excluded),
                .init(row: 4, column: 1, cellType: .included(design: .upperRight, play: [])),
                .init(row: 4, column: 2, cellType: .included(design: .upperLeft, play: [])),
                .init(row: 4, column: 3, cellType: .included(design: [], play: [])),
                .init(row: 4, column: 4, cellType: .excluded)
            ],
            [
                .init(row: 5, column: 0, cellType: .excluded),
                .init(row: 5, column: 1, cellType: .included(design: [], play: [])),
                .init(row: 5, column: 2, cellType: .included(design: [], play: [])),
                .init(row: 5, column: 3, cellType: .included(design: [], play: [])),
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
