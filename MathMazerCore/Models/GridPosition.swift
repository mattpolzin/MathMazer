//
//  GridPosition.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/9/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation

struct GridPosition: Codable, Hashable {
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
