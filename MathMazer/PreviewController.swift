//
//  PreviewController.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/8/22.
//  Copyright © 2022 Mathew Polzin. All rights reserved.
//

//import Foundation
//import SwiftUI
//import QuickLook
//import QuickLookUI
//import ReSwift
//
//struct PreviewController: NSViewControllerRepresentable {
//    let url: URL
//
//    func makeNSViewController(context: Context) -> NSController {
//        let controller = NSController()
//        return controller
//    }
//
//    func updateNSViewController(
//        _ nsViewController: NSController,
//        context: Context
//    ) {}
//
//    class NSController: NSViewController, QLPreviewingController, StoreSubscriber {
//
//        private var completionCallback: (Error?) -> Void
//
//        init() {
//            completionCallback = { _ in }
//            super.init(nibName: nil, bundle: nil)
//        }
//        required init?(coder: NSCoder) {
//            self.completionCallback = { _ in }
//            super.init(coder: coder)
//        }
//
//        func preparePreviewOfFile(
//            at url: URL,
//            completionHandler handler: @escaping (Error?) -> Void
//        ) {
//            completionCallback = handler
//            store.subscribe(self)
//            let contentView = ContentView(showControls: false, loadFile: url)
//            addChild(NSHostingController(rootView: contentView))
//        }
//
//        func newState(state: AppState) {
//            if !state.cells.isEmpty {
//                completionCallback(nil)
//            }
//        }
//    }
//}
