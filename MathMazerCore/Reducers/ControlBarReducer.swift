//
//  ControlBarReducer.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/8/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI
import ReSwift

func sizeMainWindowForGrid(rows: Int, columns: Int) {
    if let currentWindowFrame = NSApplication.shared.mainWindow?.frame {
        NSApplication.shared.mainWindow?.setFrame(
            NSRect(
                x: currentWindowFrame.minX,
                y: currentWindowFrame.minY,
                width: CGFloat(columns * 60),
                height: CGFloat(rows * 60)
            ),
            display: true
        )
    }
}

func controlBarReducer(action: ControlBarAction, state: AppState) -> AppState {
    var state = state
    switch action {
    case is ControlBarModel.TappedPlayToggle:
        state.tool.toggle()

    case is ControlBarModel.TappedReset:
        if state.tool.mode == .design {
            // TODO: move into middleware or thunk
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Reset Board?"
            alert.informativeText = "What width and height would you like your new board to be?"
            alert.accessoryView = NSHostingView(rootView: WidthHeightInputView())
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.accessoryView!.setFrameSize(.init(width: 250, height: 40))
            alert.layout()
            if alert.runModal() == .alertFirstButtonReturn {
                let inputView = (alert.accessoryView as! NSHostingView<WidthHeightInputView>).rootView
                state = AppState(width: inputView.size.width, height: inputView.size.height)
                sizeMainWindowForGrid(rows: state.rows, columns: state.columns)
            }
        } else {
            state = state.clearingPlayMode()
        }

    case is ControlBarModel.TappedSave:
        // TODO: move into middleware or thunk
        let savePanel = NSSavePanel()
        savePanel.begin { result in
            guard result == .OK,
                let url = savePanel.url else {
                    return
            }
            store.dispatch(ControlBarModel.chose(file: url, for: .save))
        }

    case is ControlBarModel.TappedOpen:
        // TODO: move into middleware or thunk
        let openPanel = NSOpenPanel()
        openPanel.begin { result in
            guard result == .OK,
                let url = openPanel.url else {
                    return
            }
            store.dispatch(ControlBarModel.chose(file: url, for: .open))
        }

    case let fileAction as ControlBarModel.ChoseFilename where fileAction.purpose == .save:
        // TODO: error handling
        // TODO: move into middleware or thunk
        try? JSONEncoder().encode(state).write(to: fileAction.file)

    case let fileAction as ControlBarModel.ChoseFilename where fileAction.purpose == .open:
        // TODO: error handling
        // TODO: move into middleware or thunk
        state = (try? JSONDecoder().decode(AppState.self, from: Data(contentsOf: fileAction.file))) ?? state
        sizeMainWindowForGrid(rows: state.rows, columns: state.columns)

    default:
        break
    }
    return state
}

struct WidthHeightInputView: View {

    final class Size: ObservableObject {
        // NOTE: due to bug with TextField using NumberFormatter not updating its bindings on text change, need to just use strings here
        @Published var widthString: String = "12"
        @Published var heightString: String = "12"

        var width: Int { Int(widthString) ?? 12 }
        var height: Int { Int(heightString) ?? 12 }

        init() {}
    }

    @ObservedObject var size: Size = .init()

    var body: some View {
        ZStack {
            HStack {
                Text("width:")
                TextField("width", text: $size.widthString)
                    .frame(width: 40)
                Spacer()
                    .frame(width: 20)
                Text("height:")
                TextField("height", text: $size.heightString)
                    .frame(width: 40)
            }
        }
    }
}
