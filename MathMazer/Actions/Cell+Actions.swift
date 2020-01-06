//
//  Cell+Actions.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/5/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation
import ReSwift

protocol CellAction: Action {
    var position: Cell.Position { get }
}

extension Cell {
    struct TappedAction: CellAction {
        let position: Position
    }

    var tapped: TappedAction {
        TappedAction(position: self.position)
    }
}
