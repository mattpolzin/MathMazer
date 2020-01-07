//
//  ContentView.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/4/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import SwiftUI

// TODO: move logic here into new models created from state rather than just passing state through. For example, instead of figuring out which mode should result in which lines being drawn, just pass the lines that need drawing in straight away.

fileprivate let lineWidth: CGFloat = 15

struct CellView: View {

    var model: Cell
    var mode: Mode
    var selected: Bool

    var borderColor: Color { selected ? .blue : .black }
    var borderWidth: CGFloat { selected ? 2.0 : 0.5 }

    var body: some View {
        ZStack {

            if model.isExcluded {
                Color.gray

                // dot counts
                countText
            } else {
                Color.white

                // start or end mark
                specialMark

                LinesView(model: model.cellType, mode: mode)
            }

            // border
            Rectangle()
                .fill(Color.clear)
                .border(borderColor, width: borderWidth)
        }
    }

    var specialMark: some View {
        typealias MarkColor = (Cell.CellType.Included.SpecialMark, Color)
        let mark: MarkColor? = model.specialMark.map {
            let color: Color
            switch $0 {
            case .start:
                color = .green
            case .end:
                color = .red

            case .dot:
                color = .black
            case .blank:
                color = .black
            }
            return ($0, color)
        }

        let shapedMark = mark.map { mark in
            ZStack {
                if mark.0 == .start || mark.0 == .end {
                    mark.1.clipShape(Circle().inset(by: lineWidth))
                } else if mark.0 == .dot {
                    mark.1.clipShape(Circle()).frame(width: lineWidth, height: lineWidth, alignment: .center)
                } else if mark.0 == .blank {
                    mark.1
                }
            }
        }

        return shapedMark
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

struct LinesView: View {

    var model: Cell.CellType
    var mode: Mode

    var body: some View {
        ZStack {
            horizontalLines
            verticalLines
        }
    }

    var horizontalLines: some View {
        HStack(spacing: 0) {

            Rectangle()
                .fill()
                .foregroundColor(.black)
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: lineWidth,
                       maxHeight: lineWidth,
                       alignment: .center)
                .opacity(model.contains(.left, for: mode) ? 1 : 0)

            Rectangle()
                .fill()
                .foregroundColor(.black)
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: lineWidth,
                       maxHeight: lineWidth,
                       alignment: .center)
                .opacity(model.contains(.right, for: mode) ? 1 : 0)
        }
    }

    var verticalLines: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if self.model.contains(.top, for: self.mode) {
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

                if self.model.contains(.bottom, for: self.mode) {
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
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(model: Cell(row: 0, column: 0, cellType: .included(design: .lowerLeft, play: [], specialMark: nil)), mode: .design, selected: false)
    }
}
