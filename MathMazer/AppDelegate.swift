//
//  AppDelegate.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/4/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Cocoa
import SwiftUI
import ReSwift

let initialWidth = 12
let initialHeight = 12

let store = Store<AppState>(
    reducer: cellGridReducer,
    state: AppState(width: initialWidth, height: initialHeight),
    middleware: [keyDownMiddleware]
)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view. 
        window = KeyTrackingWindow(
            contentRect: NSRect(x: 0, y: 0, width: initialWidth * 30, height: initialHeight * 30),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
