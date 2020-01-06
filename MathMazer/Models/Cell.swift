//
//  CellModel.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/4/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation

struct Cell: Hashable {
    var cellType: CellType
    let position: Position

    init(row: Int, column: Int, cellType: CellType = .excluded) {
        self.position = .init(row: row, column: column)
        self.cellType = cellType
    }

    var isExcluded: Bool {
        return cellType.isExcluded
    }

    var hasNoLines: Bool {
        return cellType.hasNoLines
    }

    var dotCount: DotCount? {
        return cellType.dotCount
    }

    enum CellType: Hashable {
        case excluded(dotCount: DotCount)
        case included(design: Lines, play: Lines)

        static let excluded: Self = .excluded(dotCount: .init(toTheRight: nil, below: nil))

        func contains(_ lines: Lines, for mode: Mode) -> Bool {
            switch self {
            case .excluded:
                return false
            case .included(design: let designLines, play: let playLines):
                switch mode {
                case .design:
                    return designLines.contains(lines)
                case .play:
                    return playLines.contains(lines)
                }
            }
        }

        var isExcluded: Bool {
            guard case .excluded = self else {
                return false
            }
            return true
        }

        var hasNoLines: Bool {
            switch self {
            case .excluded:
                return true
            case .included(design: let designLines, play: let playLines):
                return designLines == [] && playLines == []
            }
        }

        var dotCount: DotCount? {
            guard case .excluded(dotCount: let count) = self else {
                return nil
            }
            return count
        }

        mutating func toggle() {
            switch self {
            case .excluded:
                self = .included(design: [], play: [])
            case .included:
                self = .excluded
            }
        }

        enum Mode {
            case design
            case play
        }
    }

    struct Position: Hashable {
        let row: Int
        let column: Int
    }
}

struct DotCount: Hashable {
    /// Number of dots (cells the maze crosses through)
    /// to the right.
    let toTheRight: Int?
    /// Number of dots (cells the maze crosses through)
    /// below.
    let below: Int?

    var isBidirectional: Bool {
        return toTheRight != nil && below != nil
    }
}

struct Lines: OptionSet, Hashable {
    let rawValue: Int

    static let left = Lines(rawValue: 1 << 0)
    static let right = Lines(rawValue: 1 << 1)
    static let top = Lines(rawValue: 1 << 2)
    static let bottom = Lines(rawValue: 1 << 3)

    /// ```
    /// ___
    /// |┐|
    /// ```
    static let lowerLeft: Lines = [.left, .bottom]
    /// ```
    /// ___
    /// |┘|
    /// ```
    static let upperLeft: Lines = [.left, .top]
    /// ```
    /// ___
    /// |┌|
    /// ```
    static let lowerRight: Lines = [.right, .bottom]
    /// ```
    /// ___
    /// |└|
    /// ```
    static let upperRight: Lines = [.right, .top]

    /// ```
    /// ___
    /// |━|
    /// ```
    static let horizontal: Lines = [.left, .right]
    /// ```
    /// ___
    /// |┃|
    /// ```
    static let vertical: Lines = [.top, .bottom]
}
