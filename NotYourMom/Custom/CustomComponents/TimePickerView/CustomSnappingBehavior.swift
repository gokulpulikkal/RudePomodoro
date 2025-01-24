//
//  CustomSnappingBehavior.swift
//  NotYourMom
//
//  Created by Gokul P on 1/19/25.
//

import Foundation
import SwiftUI

/// Snaps to nearest multiple of 5
struct CustomSnappingBehavior: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let itemValue = target.rect.origin.x

        let itemWidth: CGFloat = 15 // Width of item + spacing
        let snapPoint = round(itemValue / (itemWidth * 5)) * (itemWidth * 5)
        // special handling for not setting the 0
        target.rect.origin.x = snapPoint == 0 ? 75: snapPoint
    }
}
