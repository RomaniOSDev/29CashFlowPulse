//
//  TransactionCategory.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import Foundation

enum TransactionCategory: String, CaseIterable, Codable {
    // Income
    case salary = "Salary"
    case freelance = "Freelance"
    case investment = "Investment"
    case gift = "Gift"
    
    // Expenses
    case food = "Food"
    case transport = "Transport"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case bills = "Bills"
    case health = "Health"
    case education = "Education"
    case other = "Other"
    
    var isIncome: Bool {
        switch self {
        case .salary, .freelance, .investment, .gift:
            return true
        default:
            return false
        }
    }
    
    static var incomeCategories: [TransactionCategory] {
        [.salary, .freelance, .investment, .gift]
    }
    
    static var expenseCategories: [TransactionCategory] {
        [.food, .transport, .entertainment, .shopping, .bills, .health, .education, .other]
    }
}



