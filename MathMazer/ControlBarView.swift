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
        HStack {
            Spacer()
            ZStack {
                if model.buildMode == .design {
                    Rectangle()
                        .stroke(Color.white, lineWidth: 3)
                        .foregroundColor(.clear)
                        .cornerRadius(3)
                        .frame(width: 60, height: 60, alignment: .center)
                }
                Button(action: { store.dispatch(ControlBar.tappedPlayToggle) }) {
                    Image("play_toggle")
                        .renderingMode(.template)
                        .frame(width: 50, height: 50, alignment: .center)
                        .padding(10)
                }.buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
    }
}
