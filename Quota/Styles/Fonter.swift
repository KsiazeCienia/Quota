//
//  Fonter.swift
//  Quota
//
//  Created by Marcin Włoczko on 08/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit

public enum Font {

    case muli

    var familiName: String {
        switch self {
        case .muli:
            return "Muli"
        }
    }

}

public enum FontWeight {

    case semiBold
    case regular

    var resourceName: String {
        switch self {
        case .semiBold:
            return "-SemiBold"
        case .regular:
            return ""
        }
    }
}

public class Fonter {

    public static func font(_ font: Font = .muli, size: CGFloat, weight: FontWeight) -> UIFont {
        switch font {
        case .muli:
            let fontName = font.familiName + weight.resourceName
             let font = UIFont(name: fontName, size: size)!
            return font
        }
    }
}
