//
//  CellModel.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/4/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation

struct Cell: Hashable {
    let position: Position

    var cellType: CellType

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

    var specialMark: CellType.Included.SpecialMark? {
        return cellType.specialMark
    }

    enum CellType: Hashable {
        case excluded(dotCount: DotCount)
        case included(Included)

        static let excluded: Self = .excluded(dotCount: .init(toTheRight: nil, below: nil))

        static func included(design: Lines, play: Lines, specialMark: Included.SpecialMark?) -> Self {
            return .included(
                .init(
                    designLines: design,
                    playLines: play,
                    specialMark: specialMark
                )
            )
        }

        func contains(_ lines: Lines, for mode: Mode) -> Bool {
            switch self {
            case .excluded:
                return false
            case .included(let included):
                return included.contains(lines, for: mode)
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
            case .included(let included):
                return included.designLines == [] && included.playLines == []
            }
        }

        var dotCount: DotCount? {
            guard case .excluded(dotCount: let count) = self else {
                return nil
            }
            return count
        }

        var specialMark: Included.SpecialMark? {
            guard case .included(let included) = self else {
                return nil
            }
            return included.specialMark
        }

        mutating func toggle() {
            switch self {
            case .excluded:
                self = .included(Included())
            case .included:
                self = .excluded
            }
        }

        struct Included: Hashable {
            var designLines: Lines
            var playLines: Lines
            var specialMark: SpecialMark?

            init() {
                self.init(designLines: [], playLines: [], specialMark: nil)
            }

            init(designLines: Lines, playLines: Lines, specialMark: SpecialMark?) {
                self.designLines = designLines
                self.playLines = playLines
                self.specialMark = specialMark
            }

            enum SpecialMark: Hashable {
                case start
                case end

                var toggled: SpecialMark {
                    switch self {
                    case .start:
                        return .end
                    case .end:
                        return .start
                    }
                }
            }

            func contains(_ lines: Lines, for mode: Mode) -> Bool {
                switch mode {
                case .design:
                    return designLines.contains(lines)
                case .play:
                    return playLines.contains(lines)
                }
            }
        }
    }

    struct Position: Hashable {
        let row: Int
        let column: Int

        func toTheLeft(limitedBy limit: Int = 0) -> Self {
            return .init(row: row, column: max(limit, column - 1))
        }

        func toTheRight(limitedBy limit: Int) -> Self {
            return .init(row: row, column: min(limit, column + 1))
        }

        func below(limitedBy limit: Int) -> Self {
            return .init(row: min(limit, row + 1), column: column)
        }

        func above(limitedBy limit: Int = 0 ) -> Self {
            return .init(row: max(limit, row - 1), column: column)
        }
    }

    enum Side: Hashable {
        case left
        case right
        case top
        case bottom

        var line: Lines {
            switch self {
            case .left:
                return .left
            case .right:
                return .right
            case .top:
                return .top
            case .bottom:
                return .bottom
            }
        }
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

    static func between(_ side1: Cell.Side, _ side2: Cell.Side) -> Lines? {
        switch (side1, side2) {
        case (.left, .left),
             (.right, .right),
             (.top, .top),
             (.bottom, .bottom):
            return nil

        case (.left, .right),
             (.right, .left):
            return .horizontal

        case (.top, .bottom),
             (.bottom, .top):
            return .vertical

        case (.left, .bottom),
             (.bottom, .left):
            return .lowerLeft

        case (.left, .top),
             (.top, .left):
            return .upperLeft

        case (.right, .bottom),
             (.bottom, .right):
            return .lowerRight

        case (.right, .top),
             (.top, .right):
            return .upperRight
        }
    }

    static func inDirection(of key: KeyDownAction.Key) -> Self {
        switch key {
        case .leftArrow:
            return .left
        case .rightArrow:
            return .right
        case .upArrow:
            return .top
        case .downArrow:
            return .bottom
        }
    }

    static func away(from key: KeyDownAction.Key) -> Self {
        switch key {
        case .leftArrow:
            return .right
        case .rightArrow:
            return .left
        case .upArrow:
            return .bottom
        case .downArrow:
            return .top
        }
    }
}
