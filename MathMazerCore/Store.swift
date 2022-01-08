//
//  Store.swift
//  MathMazerCore
//
//  Created by Mathew Polzin on 1/8/22.
//  Copyright © 2022 Mathew Polzin. All rights reserved.
//

import ReSwift

public let initialWidth = 12
public let initialHeight = 12

public let store = Store<AppState>(
    reducer: cellGridReducer,
    state: AppState(width: initialWidth, height: initialHeight),
    middleware: [keyDownMiddleware]
)
