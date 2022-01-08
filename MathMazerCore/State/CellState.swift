//
//  CellModel.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/4/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation

public struct CellState: Codable, Hashable {
    let position: GridPosition

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

    func hasNoLines(in mode: Mode) -> Bool {
        return cellType.hasNoLines(in: mode)
    }

    var dotCount: DotCount? {
        return cellType.dotCount
    }

    var specialMark: SpecialMark? {
        return cellType.specialMark
    }

    var clearingPlayLines: Self {
        return .init(
            row: position.row,
            column: position.column,
            cellType: cellType.clearingPlayLines
        )
    }

    var clearingDot: Self {
        return .init(
            row: position.row,
            column: position.column,
            cellType: cellType.clearingDot
        )
    }

    var clearingBlank: Self {
        return .init(
            row: position.row,
            column: position.column,
            cellType: cellType.clearingBlank
        )
    }

    enum CellType: Codable, Hashable {
        case excluded(dotCount: DotCount)
        case included(Included)

        static let excluded: Self = .excluded(dotCount: .init(toTheRight: nil, below: nil))

        static func included(design: LegalLines, play: LegalLines, specialMark: SpecialMark?) -> Self {
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
                return included.designLines == .noLines && included.playLines == .noLines
            }
        }

        func hasNoLines(in mode: Mode) -> Bool {
            switch self {
            case .excluded:
                return true
            case .included(let included):
                switch mode {
                case .design:
                    return included.designLines == .noLines
                case .play:
                    return included.playLines == .noLines
                }
            }
        }

        var clearingPlayLines: Self {
            switch self {
            case .excluded:
                return self
            case .included(let included):
                return .included(
                    .init(
                        designLines: included.designLines,
                        playLines: .noLines,
                        specialMark: included.specialMark
                    )
                )
            }
        }

        var clearingDot: Self {
            switch self {
            case .excluded:
                return self
            case .included(let included):
                return .included(
                    .init(
                        designLines: included.designLines,
                        playLines: included.playLines,
                        specialMark: included.specialMark == .dot
                            ? nil
                            : included.specialMark
                    )
                )
            }
        }

        var clearingBlank: Self {
            switch self {
            case .excluded:
                return self
            case .included(let included):
                return .included(
                    .init(
                        designLines: included.designLines,
                        playLines: included.playLines,
                        specialMark: included.specialMark == .blank
                            ? nil
                            : included.specialMark
                    )
                )
            }
        }

        var dotCount: DotCount? {
            guard case .excluded(dotCount: let count) = self else {
                return nil
            }
            return count
        }

        var specialMark: SpecialMark? {
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

        struct Included: Codable, Hashable {
            var designLines: LegalLines
            var playLines: LegalLines
            var specialMark: SpecialMark?

            init() {
                self.init(designLines: .noLines, playLines: .noLines, specialMark: nil)
            }

            init(designLines: LegalLines, playLines: LegalLines, specialMark: SpecialMark?) {
                self.designLines = designLines
                self.playLines = playLines
                self.specialMark = specialMark
            }

            func contains(_ lines: Lines, for mode: Mode) -> Bool {
                switch mode {
                case .design:
                    return designLines.lines.contains(lines)
                case .play:
                    return playLines.lines.contains(lines)
                }
            }

            func togglingMarkForDesign() -> Self {
                .init(
                    designLines: designLines,
                    playLines: playLines,
                    specialMark: specialMark?.toggledForDesign ?? .start
                )
            }

            func togglingDot() -> Self {
                .init(
                    designLines: designLines,
                    playLines: playLines,
                    specialMark: specialMark == nil
                        ? .dot
                        : specialMark == .dot
                            ? nil
                            : specialMark
                )
            }

            func togglingBlank() -> Self {
                .init(
                    designLines: designLines,
                    playLines: playLines,
                    specialMark: specialMark == nil
                        ? .blank
                        : specialMark == .blank
                            ? nil
                            : specialMark
                )
            }
        }
    }
}

struct DotCount: Codable, Hashable {
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

struct LegalLines: Codable, Hashable {
    let lines: Lines

    private init(forcing lines: Lines) {
        self.lines = lines
    }

    init?(_ lines: Lines) {
        guard Self.legalLines.contains(lines) else {
            return nil
        }

        self.lines = lines
    }

    func union(_ other: Lines) -> LegalLines? {
        return LegalLines(lines.union(other))
    }

    static let noLines: Self = .init(forcing: [])
    static let lowerLeft: Self = .init(forcing: .lowerLeft)
    static let upperLeft: Self = .init(forcing: .upperLeft)
    static let lowerRight: Self = .init(forcing: .lowerRight)
    static let upperRight: Self = .init(forcing: .upperRight)
    static let horizontal: Self = .init(forcing: .horizontal)
    static let vertical: Self = .init(forcing: .vertical)

    static let legalLines: [Lines] = [
        [],

        .left, .right, .top, .bottom,

        .horizontal, .vertical,

        .lowerLeft, .lowerRight,
        .upperLeft, .upperRight
    ]

    func encode(to encoder: Encoder) throws {
        try lines.encode(to: encoder)
    }

    init(from decoder: Decoder) throws {
        lines = try .init(from: decoder)
    }
}

struct Lines: OptionSet, Codable, Hashable {
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

    static func between(_ side1: Side, _ side2: Side) -> Lines? {
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

extension CellState.CellType {
    enum CodingKeys: String, CodingKey {
        case included
        case dotCount
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.included) {
            self = .included(try container.decode(Included.self, forKey: .included))
        } else {
            self = .excluded(dotCount: try container.decode(DotCount.self, forKey: .dotCount))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .included(let included):
            try container.encode(included, forKey: .included)
        case .excluded(dotCount: let count):
            try container.encode(count, forKey: .dotCount)
        }
    }
}
