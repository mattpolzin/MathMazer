//
//  ContentView.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/4/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import SwiftUI
import ReSwift

struct ContentView: View {
    @ObservedObject private var appState = ObservableState(store: store)

    var body: some View {
        VStack(spacing: 0) {
            ForEach(appState.current.cells, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { cell in
                        CellView(model: cell)
                            .onTapGesture {
                                store.dispatch(cell.tapped)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
