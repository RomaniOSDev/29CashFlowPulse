//
//  Achievement.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import Foundation
import SwiftUI

struct Achievement: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var iconName: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var progress: Double // 0.0 to 1.0
    var targetValue: Double
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        iconName: String,
        isUnlocked: Bool = false,
        unlockedDate: Date? = nil,
        progress: Double = 0.0,
        targetValue: Double
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
        self.progress = progress
        self.targetValue = targetValue
    }
    
    var progressPercentage: Int {
        Int(min(progress * 100, 100))
    }
}

enum AchievementType: String, CaseIterable {
    case firstTransaction = "First Transaction"
    case tenTransactions = "10 Transactions"
    case fiftyTransactions = "50 Transactions"
    case hundredTransactions = "100 Transactions"
    case thousandBalance = "$1,000 Balance"
    case tenThousandBalance = "$10,000 Balance"
    case positiveBalance = "Positive Balance"
    case weekStreak = "7 Day Streak"
    case monthStreak = "30 Day Streak"
    case perfectWeek = "Perfect Week"
    case saver = "Saver"
    case bigSpender = "Big Spender"
}


