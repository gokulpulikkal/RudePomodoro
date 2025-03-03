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
    var isEntitled = true // Change this to false when wanted to include payments

    func checkEntitlement() {
        Purchases.shared.getCustomerInfo { customerInfo, _ in
            if let entitlements = customerInfo?.entitlements.active, entitlements["pro"] != nil {
                self.isEntitled = true
            } else {
                self.isEntitled = true // Change this to false when wanted to include payments
            }
        }
    }
}
