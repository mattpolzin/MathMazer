//
//  ContentView.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/4/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import SwiftUI

fileprivate let lineWidth: CGFloat = 15

struct CellView: View {

    @State var model: Cell

    var body: some View {
        ZStack {

            if model.cellType.isExcluded {
                Color.gray

                // dot counts
                countText
            } else {
                Color.white
            }

            // border
            Rectangle()
                .fill(Color.clear)
                .border(Color.black, width: 0.5)

            // maze lines
            horizontalLines
            verticalLines
        }
    }

    var horizontalLines: some View {
        HStack(spacing: 0) {

            if model.cellType.contains(.left, for: .design) {
                Rectangle()
                    .fill()
                    .foregroundColor(.black)
                    .frame(minWidth: 0,
                           maxWidth: .infinity,
                           minHeight: lineWidth,
                           maxHeight: lineWidth,
                           alignment: .center)
            } else {
                Spacer()
                    .frame(minWidth: 0,
                           maxWidth: .infinity,
                           minHeight: lineWidth,
                           maxHeight: lineWidth,
                           alignment: .center)
            }

            if model.cellType.contains(.right, for: .design) {
                Rectangle()
                    .fill()
                    .foregroundColor(.black)
                    .frame(minWidth: 0,
                           maxWidth: .infinity,
                           minHeight: lineWidth,
                           maxHeight: lineWidth,
                           alignment: .center)
            } else {
                Spacer()
                    .frame(minWidth: 0,
                           maxWidth: .infinity,
                           minHeight: lineWidth,
                           maxHeight: lineWidth,
                           alignment: .center)
            }
        }
    }

    var verticalLines: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if self.model.cellType.contains(.top, for: .design) {
                    Rectangle()
                        .fill()
                        .foregroundColor(.black)
                        .frame(minWidth: lineWidth,
                               maxWidth: lineWidth,
                               minHeight: 0,
                               maxHeight: .infinity,
                               alignment: .center)
                } else {
                    Spacer()
                        .frame(width: lineWidth,
                               height: (geometry.size.height - lineWidth) / 2,
                               alignment: .top)
                }

                if self.model.cellType.contains(.bottom, for: .design) {
                    Rectangle()
                        .fill()
                        .foregroundColor(.black)
                        .frame(minWidth: lineWidth,
                               maxWidth: lineWidth,
                               minHeight: 0,
                               maxHeight: .infinity,
                               alignment: .center)
                } else {
                    Spacer()
                        .frame(width: lineWidth,
                               height: (geometry.size.height - lineWidth) / 2,
                               alignment: .bottom)
                }
            }
        }
    }

    var countText: some View {
        ZStack {
            model.dotCount?.toTheRight.map { count in
                VStack {
                    Text("\(count)")
                        .foregroundColor(.black)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 6))
                }
            }

            model.dotCount?.below.map { count in
                HStack {
                    Text("\(count)")
                        .foregroundColor(.black)
                        .font(.headline)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
                }
            }

            if model.dotCount?.isBidirectional ?? false {
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: .init(x: geometry.size.width / 2, y: geometry.size.height / 2))
                        path.addLine(to: .init(x: geometry.size.width, y: geometry.size.height))
                    }.stroke(style: StrokeStyle(lineWidth: 2, dash: [2]))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(model: Cell(row: 0, column: 0, cellType: .included(design: .lowerLeft, play: [])))
    }
}
