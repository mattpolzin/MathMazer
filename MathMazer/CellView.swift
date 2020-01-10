//
//  ContentView.swift
//  MathMazer
//
//  Created by Mathew Polzin on 1/4/20.
//  Copyright © 2020 Mathew Polzin. All rights reserved.
//

import SwiftUI

// TODO: move logic here into new models created from state rather than just passing state through. For example, instead of figuring out which mode should result in which lines being drawn, just pass the lines that need drawing in straight away.

fileprivate let lineWidth: CGFloat = 8
fileprivate let dotSize: CGFloat = 15

struct CellView: View {

    var model: CellModel

    var borderColor: Color { model.isSelected ? .blue : .gray }
    var borderWidth: CGFloat { model.isSelected ? 2.0 : 0.5 }

    var body: some View {
        ZStack {

            // background color
            model.isExcluded ? Color.gray : Color.white

            // border
            if model.hasBorder {
                Rectangle()
                    .fill(Color.clear)
                    .border(borderColor, width: borderWidth)
            }

            if model.isExcluded {
                // dot counts
                countText
            } else {
                // start or end mark
                specialMark

                LinesView(model: model.lines)
            }
        }
    }

    var specialMark: some View {
        typealias MarkColor = (SpecialMark, Color)
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
                    mark.1.clipShape(Circle().inset(by: dotSize))
                    Color.black.clipShape(Circle()).frame(width: dotSize, height: dotSize, alignment: .center)
                } else if mark.0 == .dot {
                    mark.1.clipShape(Circle()).frame(width: dotSize, height: dotSize, alignment: .center)
                } else if mark.0 == .blank {
                    mark.1
                }
            }
        }

        return shapedMark
    }

    var countText: some View {
        ZStack {
            model.horizontalDotCount.map { count in
                VStack {
                    Text("\(count)")
                        .foregroundColor(.black)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4))
                }
            }

            model.verticalDotCount.map { count in
                HStack {
                    Text("\(count)")
                        .foregroundColor(.black)
                        .font(.headline)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                }
            }

            if model.hasBidirectionalDotCount {
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: .init(x: geometry.size.width / 2, y: (geometry.size.height * 2) / 5))
                        path.addLine(to: .init(x: geometry.size.width, y: geometry.size.height))
                    }.stroke(style: StrokeStyle(lineWidth: 2, dash: [2]))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct LinesView: View {

    var model: Lines

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
                .opacity(model.contains(.left) ? 1 : 0)

            Rectangle()
                .fill()
                .foregroundColor(.black)
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: lineWidth,
                       maxHeight: lineWidth,
                       alignment: .center)
                .opacity(model.contains(.right) ? 1 : 0)
        }
    }

    var verticalLines: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if self.model.contains(.top) {
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

                if self.model.contains(.bottom) {
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
        CellView(model: CellModel(state: CellState(row: 0, column: 0, cellType: .included(design: .noLines, play: .noLines, specialMark: nil)), for: .design, selected: false))
    }
}
