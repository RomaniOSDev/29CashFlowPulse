//
//  CashFlowDay.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import Foundation

struct CashFlowDay: Identifiable, Codable {
    let id: UUID
    var date: Date
    var transactions: [FinancialTransaction]
    
    init(id: UUID = UUID(), date: Date, transactions: [FinancialTransaction] = []) {
        self.id = id
        self.date = date
        self.transactions = transactions
    }
    
    var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var netFlow: Double {
        totalIncome - totalExpense
    }
    
    var flowIntensity: Double {
        // Flow intensity for the day (0-1)
        let total = totalIncome + totalExpense
        guard total > 0 else { return 0 }
        return min(total / 5000.0, 1.0)
    }
}



