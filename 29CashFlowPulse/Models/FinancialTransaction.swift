//
//  FinancialTransaction.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import Foundation
import SwiftUI

struct FinancialTransaction: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var type: TransactionType
    var category: TransactionCategory
    var date: Date
    var description: String?
    var location: String?
    var isRecurring: Bool = false
    
    init(
        id: UUID = UUID(),
        amount: Double,
        type: TransactionType,
        category: TransactionCategory,
        date: Date = Date(),
        description: String? = nil,
        location: String? = nil,
        isRecurring: Bool = false
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.date = date
        self.description = description
        self.location = location
        self.isRecurring = isRecurring
    }
    
    var pulseColor: Color {
        switch type {
        case .income: return Color(hex: "00FF88")
        case .expense: return Color(hex: "FF4757")
        }
    }
    
    var pulseIntensity: Double {
        // Intensity depends on amount
        min(abs(amount) / 1000.0, 1.0)
    }
}



