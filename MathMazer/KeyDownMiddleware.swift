//
//  KeyDownMiddleware.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/6/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation
import ReSwift

func keyDownMiddleware(dispatch: @escaping DispatchFunction, getState: @escaping () -> AppState?) -> (@escaping DispatchFunction) -> DispatchFunction {
    return { next in
        return { action in
            if let keyAction = action as? KeyDownAction,
                let selectedCellPosition = getState()?.selectedCellPosition {
                return next(
                    CellModel.KeyDownAction(
                        position: selectedCellPosition,
                        key: keyAction.key
                    )
                )
            }
            return next(action)
        }
    }
}
