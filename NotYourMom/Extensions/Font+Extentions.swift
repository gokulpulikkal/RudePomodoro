//
//  Font+Extentions.swift
//  NotYourMom
//
//  Created by Gokul P on 1/22/25.
//

import SwiftUI

extension Font {
    enum SourGummy {
        case regular
        case medium
        case bold

        var value: String {
            switch self {
            case .regular:
                "SourGummySemiExpanded-Regular"
            case .medium:
                "SourGummySemiExpanded-Medium"
            case .bold:
                "SourGummySemiExpanded-Bold"
            }
        }
    }

    static func sourGummy(_ type: SourGummy, size: CGFloat = 26) -> Font {
        .custom(type.value, size: size)
    }
}
