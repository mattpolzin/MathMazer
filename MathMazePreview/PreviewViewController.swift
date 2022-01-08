//
//  PreviewViewController.swift
//  MathMazePreview
//
//  Created by Mathew Polzin on 1/8/22.
//  Copyright © 2022 Mathew Polzin. All rights reserved.
//

import Foundation
import SwiftUI
import QuickLook
import QuickLookUI
import ReSwift
import MathMazerCore

class PreviewViewController: NSViewController, QLPreviewingController, StoreSubscriber {

    private var completionCallback: (Error?) -> Void

    init() {
        self.completionCallback = { _ in }
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.completionCallback = { _ in }
        super.init(coder: coder)
    }

    func preparePreviewOfFile(
        at url: URL,
        completionHandler handler: @escaping (Error?) -> Void
    ) {
        completionCallback = handler
        store.subscribe(self)
        let contentView = ContentView(showControls: false, loadFile: url)
        let controller = NSHostingController(rootView: contentView)
        addChild(controller)
        controller.view.frame = self.view.frame
        self.view.autoresizesSubviews = true
        self.view.addSubview(controller.view)
    }

    func newState(state: AppState) {
        if !state.cells.isEmpty {
            completionCallback(nil)
        }
    }
}
