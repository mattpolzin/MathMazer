//
//  ControlBarView.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/5/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import Foundation
import SwiftUI

struct ControlBarView: View {

    var model: ControlBar

    var body: some View {
        ZStack {
            if model.buildMode == .design {
                Rectangle()
                    .stroke(Color.white, lineWidth: 3)
                    .foregroundColor(.clear)
                    .cornerRadius(3)
                    .frame(width: 36, height: 36, alignment: .center)
                Image("design")
                    .renderingMode(.template)
                    .frame(width: 30, height: 30, alignment: .center)
                    .padding(10)
                    .onTapGesture {
                        store.dispatch(ControlBar.tappedPlayToggle)
                }
            } else {
                Image("play")
                    .renderingMode(.template)
                    .frame(width: 30, height: 30, alignment: .center)
                    .padding(10)
                    .onTapGesture {
                        store.dispatch(ControlBar.tappedPlayToggle)
                }
            }
            HStack {
                Spacer()
                Button(action: { store.dispatch(ControlBar.tappedSave) }) {
                    Image("save")
                        .renderingMode(.template)
                        .frame(width: 30, height: 30, alignment: .center)
                        .padding(10)
                }.buttonStyle(PlainButtonStyle())
                Button(action: { store.dispatch(ControlBar.tappedOpen) }) {
                    Image("open")
                        .renderingMode(.template)
                        .frame(width: 30, height: 30, alignment: .center)
                        .padding(10)
                }.buttonStyle(PlainButtonStyle())
            }
        }

    }
}
