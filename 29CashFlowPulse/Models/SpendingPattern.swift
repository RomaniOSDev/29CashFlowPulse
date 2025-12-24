//
//  SpendingPattern.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import Foundation

struct SpendingPattern: Identifiable, Codable {
    let id: UUID
    var category: TransactionCategory
    var averageAmount: Double
    var frequency: Frequency
    var lastOccurrence: Date
    
    init(
        id: UUID = UUID(),
        category: TransactionCategory,
        averageAmount: Double,
        frequency: Frequency,
        lastOccurrence: Date
    ) {
        self.id = id
        self.category = category
        self.averageAmount = averageAmount
        self.frequency = frequency
        self.lastOccurrence = lastOccurrence
    }
}



