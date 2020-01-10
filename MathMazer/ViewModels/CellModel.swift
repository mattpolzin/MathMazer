//
//  Cell.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/9/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation
import SwiftUI

struct CellModel: Hashable {
    public let position: GridPosition
    public let lines: Lines
    public let horizontalDotCount: Int?
    public let verticalDotCount: Int?
    public let specialMark: SpecialMark?
    public let isExcluded: Bool
    public let isSelected: Bool

    public var hasBidirectionalDotCount: Bool {
        return horizontalDotCount != nil && verticalDotCount != nil
    }

    public var hasBorder: Bool {
        return specialMark != .blank
    }

    init(state cellState: CellState, for mode: Mode, selected: Bool) {
        self.position = cellState.position
        self.isSelected = selected
        switch cellState.cellType {
        case .excluded(dotCount: let dotCount):
            isExcluded = true
            horizontalDotCount = dotCount.toTheRight
            verticalDotCount = dotCount.below
            lines = []
            specialMark = nil

        case .included(let included):
            isExcluded = false
            horizontalDotCount = nil
            verticalDotCount = nil
            lines = (mode == .design ? included.designLines : included.playLines)
                .lines
            specialMark = included.specialMark
        }
    }
}

extension CellModel: Identifiable {
    public var id: GridPosition { position }
}
