//
//  Rectangle.swift
//  Quota
//
//  Created by Marcin Włoczko on 04/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class Rectangle {
    let inset: CGFloat = 30
    let initOffset: CGFloat = 15
    var frame: BehaviorRelay<CGRect>
    var topLeftCorner: CGPoint
    var topRightCorner: CGPoint
    var bottomLeftCorner: CGPoint
    var bottomRightCorner: CGPoint
    private var leftLine: Line {
        return  Line(point1: topLeftCorner, point2: bottomLeftCorner)
    }
    private var topLine: Line {
        return Line(point1: topLeftCorner, point2: topRightCorner)
    }
    private var rightLine: Line {
        return Line(point1: topRightCorner, point2: bottomRightCorner)
    }
    private var bottomLine: Line {
        return Line(point1: bottomLeftCorner, point2: bottomRightCorner)
    }
    private var lines: [Line] {
        return [leftLine, topLine, rightLine, bottomLine]
    }

    init(frame: CGRect) {
        self.frame = BehaviorRelay<CGRect>(value: frame)

        topLeftCorner = CGPoint(x: initOffset, y: initOffset)
        topRightCorner = CGPoint(x: frame.width - initOffset, y: initOffset)
        bottomLeftCorner = CGPoint(x: initOffset, y: frame.height - initOffset)
        bottomRightCorner = CGPoint(x: frame.width - initOffset, y: frame.height - initOffset)

        updateFrame()
    }

    func moveClosest(to point: CGPoint) {

        if point.distanceFrom(line: leftLine) < inset {
            topLeftCorner = CGPoint(x: point.x, y: topLeftCorner.y)
            bottomLeftCorner = CGPoint(x: point.x, y: bottomLeftCorner.y)
        }
        if point.distanceFrom(line: rightLine) < inset {
            topRightCorner = CGPoint(x: point.x, y: topRightCorner.y)
            bottomRightCorner = CGPoint(x: point.x, y: bottomRightCorner.y)
        }
        if point.distanceFrom(line: topLine) < inset {
            topLeftCorner = CGPoint(x: topLeftCorner.x, y: point.y)
            topRightCorner = CGPoint(x: topRightCorner.x, y: point.y)
        }
        if point.distanceFrom(line: bottomLine) < inset {
            bottomRightCorner = CGPoint(x: bottomRightCorner.x, y: point.y)
            bottomLeftCorner = CGPoint(x: bottomLeftCorner.x, y: point.y)
        }

        updateFrame()
    }

    func contains(point: CGPoint) -> Bool {
        return lines.contains(where: {
            return point.distanceFrom(line: $0) < inset
        })
    }

    private func updateFrame() {
        frame.accept(CGRect(x: topLeftCorner.x, y: topLeftCorner.y,
                       width: topRightCorner.x - topLeftCorner.x,
                       height: bottomLeftCorner.y - topLeftCorner.y))
    }
}
