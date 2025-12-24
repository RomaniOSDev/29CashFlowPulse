//
//  PulseAnimationSystem.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import SwiftUI

struct PulseAnimationSystem {
    static func createPulse(for transaction: FinancialTransaction, at position: CGPoint) -> FinancialPulse {
        FinancialPulse(
            position: position,
            color: transaction.pulseColor,
            intensity: transaction.pulseIntensity,
            lifetime: 3.0,
            isActive: true
        )
    }
    
    static func createWave(for amount: Double, type: TransactionType) -> some View {
        let color = type == .income ? Color.incomeColor : Color.expenseColor
        let scale = min(abs(amount) / 1000.0 * 2.0, 3.0)
        
        return Circle()
            .stroke(color.opacity(0.3), lineWidth: 2)
            .frame(width: 50, height: 50)
            .scaleEffect(scale)
            .opacity(0)
            .animation(
                Animation.easeOut(duration: 2.0)
                    .repeatCount(1, autoreverses: false),
                value: scale
            )
    }
}



