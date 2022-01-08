//
//  ContentView.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/4/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import SwiftUI
import ReSwift

public struct ContentView: View {
    @ObservedObject private var appState = ObservableState(store: store)

    let showControls: Bool

    public init(showControls: Bool = true, loadFile: URL? = nil) {
        self.showControls = showControls
        if let file = loadFile {
            store.dispatch(ControlBarModel.chose(file: file, for: .open))
        }
    }

    public var body: some View {
        func dragGesture(for cell: CellModel, within frame: CGSize) -> some Gesture {
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

        func tapGesture(for cell: CellModel) -> some Gesture {
            TapGesture()
                .onEnded {
                    store.dispatch(cell.tapped)
            }
        }

        func ctrlClickGesture(for cell: CellModel) -> some Gesture {
            TapGesture()
                .modifiers(.control)
                .onEnded { _ in
                    store.dispatch(cell.ctrlClicked)
            }
        }

        func shiftClickGesture(for cell: CellModel) -> some Gesture {
            TapGesture()
                .modifiers(.shift)
                .onEnded { _ in
                    store.dispatch(cell.shiftClicked)
            }
        }

        let controlBar = appState.current.controlBar
        let toolMode = appState.current.tool.mode
        let selectedCellPosition = appState.current.selectedCellPosition

        func cellModel(for cell: CellState) -> CellModel {
            return CellModel(
                state: cell,
                for: toolMode,
                selected: selectedCellPosition.map { $0 == cell.position } ?? false
            )
        }

        let cells = appState.current.cells.map { $0.map(cellModel) }

        return VStack(spacing: 0) {
            if showControls {
                ControlBarView(model: controlBar)
            }
            ForEach(cells, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { cellModel in
                        GeometryReader { geometry in
                            CellView(model: cellModel)
                            .gesture(
                                dragGesture(for: cellModel, within: geometry.size)
                                    .exclusively(before: shiftClickGesture(for: cellModel))
                                    .exclusively(before: ctrlClickGesture(for: cellModel))
                                    .exclusively(before: tapGesture(for: cellModel))
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

func closestSide(for point: CGPoint, within frame: CGSize) -> Side {
    let distances: [(Side, CGFloat)] = [
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
