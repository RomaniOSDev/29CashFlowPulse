//
//  FinancialPulse.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import Foundation
import SwiftUI

struct FinancialPulse: Identifiable {
    let id: UUID
    var position: CGPoint
    var color: Color
    var intensity: Double
    var lifetime: TimeInterval
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        position: CGPoint,
        color: Color,
        intensity: Double,
        lifetime: TimeInterval,
        isActive: Bool = true
    ) {
        self.id = id
        self.position = position
        self.color = color
        self.intensity = intensity
        self.lifetime = lifetime
        self.isActive = isActive
    }
}



