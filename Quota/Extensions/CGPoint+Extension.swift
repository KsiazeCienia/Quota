//
//  CGPoint+Extension.swift
//  Quota
//
//  Created by Marcin Włoczko on 04/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit

extension CGPoint {

    func distanceFrom(point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }

    func distanceFrom(line: Line) -> CGFloat {

        let A = line.point1.y - line.point2.y
        let B = line.point2.x - line.point1.x
        let C = line.point1.x * line.point2.y - line.point2.x * line.point1.y

        let distance = A * x + B * y + C

        return abs(distance/sqrt(A*A + B*B))
    }
}
