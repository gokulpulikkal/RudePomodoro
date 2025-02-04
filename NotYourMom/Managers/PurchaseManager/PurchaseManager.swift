//
//  PurchaseManager.swift
//  NotYourMom
//
//  Created by Gokul P on 2/4/25.
//

import Foundation
import RevenueCat
import SwiftUI

@Observable
@MainActor
class PurchaseManager {
    var isEntitled = false

    func checkEntitlement() {
        Purchases.shared.getCustomerInfo { customerInfo, _ in
            if let entitlements = customerInfo?.entitlements.active, entitlements["pro"] != nil {
                self.isEntitled = true
            } else {
                self.isEntitled = false
            }
        }
    }
}
