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
        func dragGesture(for cell: Cell, within frame: CGSize) -> some Gesture {
            DragGesture()
                .onEnded { value in
                    store.dispatch(
                        cell.dragging(
                            from: closestSide(for: value.startLocation, within: frame),
                            to: closestSide(for: value.location, within: frame)
                        )
                    )
            }
        }

        func tapGesture(for cell: Cell) -> some Gesture {
            TapGesture()
                .onEnded {
                    store.dispatch(cell.tapped)
            }
        }

        func ctrlClickGesture(for cell: Cell) -> some Gesture {
            TapGesture()
                .modifiers(.control)
                .onEnded { _ in
                    store.dispatch(cell.ctrlClicked)
            }
        }

        func shiftClickGesture(for cell: Cell) -> some Gesture {
            TapGesture()
                .modifiers(.shift)
                .onEnded { _ in
                    store.dispatch(cell.shiftClicked)
            }
        }

        let cells = appState.current.cells
        let controlBar = appState.current.controlBar
        let toolMode = appState.current.tool.mode
        let selectedCellPosition = appState.current.selectedCellPosition

        return VStack(spacing: 0) {
            ControlBarView(model: controlBar)
            ForEach(cells, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { cell in
                        GeometryReader { geometry in
                            CellView(model: cell, mode: toolMode, selected: selectedCellPosition.map { $0 == cell.position } ?? false)
                            .gesture(
                                dragGesture(for: cell, within: geometry.size)
                                    .exclusively(before: shiftClickGesture(for: cell))
                                    .exclusively(before: ctrlClickGesture(for: cell))
                                    .exclusively(before: tapGesture(for: cell))
                            )
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

func closestSide(for point: CGPoint, within frame: CGSize) -> Cell.Side {
    let distances: [(Cell.Side, CGFloat)] = [
        (.left, point.x),
        (.right, frame.width - point.x),
        (.top, point.y),
        (.bottom, frame.height - point.y)
    ]
    return distances
        .sorted { $0.1 < $1.1 }
        .first!
        .0
}
