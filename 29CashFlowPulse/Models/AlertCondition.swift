//
//  AlertCondition.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import Foundation

enum AlertCondition: String, CaseIterable, Codable {
    case unusualSpending = "Unusual Spending"
    case largeTransaction = "Large Transaction"
    case incomeDrop = "Income Drop"
    case budgetExceeded = "Budget Exceeded"
}


