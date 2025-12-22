//
//  CashFlowViewModel.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import Foundation
import SwiftUI
import Combine

class CashFlowViewModel: ObservableObject {
    @Published var transactions: [FinancialTransaction] = []
    @Published var dailyFlows: [CashFlowDay] = []
    @Published var currentBalance: Double = 0.0
    @Published var activePulses: [FinancialPulse] = []
    @Published var spendingPatterns: [SpendingPattern] = []
    @Published var alertRules: [AlertRule] = []
    @Published var achievements: [Achievement] = []
    
    @Published var todayIncome: Double = 0.0
    @Published var todayExpense: Double = 0.0
    @Published var weekIncome: Double = 0.0
    @Published var weekExpense: Double = 0.0
    @Published var monthIncome: Double = 0.0
    @Published var monthExpense: Double = 0.0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        setupSubscriptions()
        initializeDefaultAlerts()
        initializeAchievements()
    }
    
    private func setupSubscriptions() {
        $transactions
            .sink { [weak self] transactions in
                self?.updateStatistics()
                self?.updateDailyFlows()
                self?.detectPatterns()
                self?.checkAchievements()
            }
            .store(in: &cancellables)
        
        $currentBalance
            .sink { [weak self] _ in
                self?.checkAchievements()
            }
            .store(in: &cancellables)
    }
    
    func addTransaction(_ transaction: FinancialTransaction) {
        transactions.append(transaction)
        currentBalance += transaction.type == .income ? transaction.amount : -transaction.amount
        
        // Create pulse animation
        let centerPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        let pulse = PulseAnimationSystem.createPulse(for: transaction, at: centerPosition)
        activePulses.append(pulse)
        
        // Remove pulse after lifetime
        DispatchQueue.main.asyncAfter(deadline: .now() + pulse.lifetime) { [weak self] in
            self?.activePulses.removeAll { $0.id == pulse.id }
        }
        
        checkAlerts(for: transaction)
        saveData()
    }
    
    func deleteTransaction(_ transaction: FinancialTransaction) {
        transactions.removeAll { $0.id == transaction.id }
        currentBalance -= transaction.type == .income ? transaction.amount : -transaction.amount
        saveData()
    }
    
    private func updateStatistics() {
        let calendar = Calendar.current
        let now = Date()
        
        // Today
        let todayStart = calendar.startOfDay(for: now)
        let todayTransactions = transactions.filter { $0.date >= todayStart }
        todayIncome = todayTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        todayExpense = todayTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        // Week
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let weekTransactions = transactions.filter { $0.date >= weekStart }
        weekIncome = weekTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        weekExpense = weekTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        // Month
        let monthStart = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let monthTransactions = transactions.filter { $0.date >= monthStart }
        monthIncome = monthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        monthExpense = monthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    private func updateDailyFlows() {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        
        dailyFlows = grouped.map { date, transactions in
            CashFlowDay(date: date, transactions: transactions)
        }.sorted { $0.date > $1.date }
    }
    
    func getTransactions(for date: Date) -> [FinancialTransaction] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date
        
        return transactions.filter { transaction in
            transaction.date >= dayStart && transaction.date < dayEnd
        }.sorted { $0.date > $1.date }
    }
    
    private func detectPatterns() {
        // Simple pattern detection
        let calendar = Calendar.current
        var categoryStats: [TransactionCategory: [Double]] = [:]
        
        for transaction in transactions {
            if categoryStats[transaction.category] == nil {
                categoryStats[transaction.category] = []
            }
            categoryStats[transaction.category]?.append(transaction.amount)
        }
        
        spendingPatterns = categoryStats.compactMap { category, amounts in
            guard !amounts.isEmpty else { return nil }
            let average = amounts.reduce(0, +) / Double(amounts.count)
            
            // Simple frequency detection
            let frequency: Frequency = amounts.count > 20 ? .daily : amounts.count > 5 ? .weekly : .monthly
            
            let lastTransaction = transactions
                .filter { $0.category == category }
                .max(by: { $0.date < $1.date })
            
            return SpendingPattern(
                category: category,
                averageAmount: average,
                frequency: frequency,
                lastOccurrence: lastTransaction?.date ?? Date()
            )
        }
    }
    
    private func checkAlerts(for transaction: FinancialTransaction) {
        for index in alertRules.indices {
            guard alertRules[index].isEnabled else { continue }
            
            var shouldTrigger = false
            
            switch alertRules[index].condition {
            case .largeTransaction:
                shouldTrigger = abs(transaction.amount) > 1000
            case .unusualSpending:
                // Check if amount is significantly different from average
                let categoryPattern = spendingPatterns.first { $0.category == transaction.category }
                if let pattern = categoryPattern {
                    let deviation = abs(transaction.amount - pattern.averageAmount) / pattern.averageAmount
                    shouldTrigger = deviation > 0.5 && transaction.type == .expense
                }
            case .incomeDrop:
                // Check if income decreased significantly
                if transaction.type == .income {
                    let recentIncome = transactions
                        .filter { $0.type == .income && $0.date > Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date() }
                        .reduce(0) { $0 + $1.amount }
                    let previousIncome = transactions
                        .filter { $0.type == .income && $0.date <= Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date() && $0.date > Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date() }
                        .reduce(0) { $0 + $1.amount }
                    shouldTrigger = previousIncome > 0 && recentIncome < previousIncome * 0.7
                }
            case .budgetExceeded:
                // Simple budget check
                shouldTrigger = monthExpense > monthIncome * 1.2
            }
            
            if shouldTrigger {
                alertRules[index].triggerCount += 1
            }
        }
    }
    
    func initializeDefaultAlerts() {
        alertRules = [
            AlertRule(name: "Large Transaction Alert", condition: .largeTransaction),
            AlertRule(name: "Unusual Spending Alert", condition: .unusualSpending),
            AlertRule(name: "Income Drop Alert", condition: .incomeDrop),
            AlertRule(name: "Budget Exceeded Alert", condition: .budgetExceeded)
        ]
    }
    
    // MARK: - Achievements
    
    func initializeAchievements() {
        if achievements.isEmpty {
            achievements = [
                Achievement(
                    title: "First Steps",
                    description: "Add your first transaction",
                    iconName: "star.fill",
                    targetValue: 1
                ),
                Achievement(
                    title: "Getting Started",
                    description: "Add 10 transactions",
                    iconName: "star.circle.fill",
                    targetValue: 10
                ),
                Achievement(
                    title: "Regular User",
                    description: "Add 50 transactions",
                    iconName: "star.circle",
                    targetValue: 50
                ),
                Achievement(
                    title: "Power User",
                    description: "Add 100 transactions",
                    iconName: "crown.fill",
                    targetValue: 100
                ),
                Achievement(
                    title: "Thousandaire",
                    description: "Reach $1,000 balance",
                    iconName: "dollarsign.circle.fill",
                    targetValue: 1000
                ),
                Achievement(
                    title: "Ten Thousandaire",
                    description: "Reach $10,000 balance",
                    iconName: "dollarsign.square.fill",
                    targetValue: 10000
                ),
                Achievement(
                    title: "In the Green",
                    description: "Have a positive balance",
                    iconName: "arrow.up.circle.fill",
                    targetValue: 1
                ),
                Achievement(
                    title: "Week Warrior",
                    description: "Use app for 7 days straight",
                    iconName: "calendar.badge.clock",
                    targetValue: 7
                ),
                Achievement(
                    title: "Month Master",
                    description: "Use app for 30 days straight",
                    iconName: "calendar",
                    targetValue: 30
                ),
                Achievement(
                    title: "Perfect Week",
                    description: "Add transactions every day for a week",
                    iconName: "checkmark.seal.fill",
                    targetValue: 7
                ),
                Achievement(
                    title: "Saver",
                    description: "Save more than you spend in a month",
                    iconName: "banknote.fill",
                    targetValue: 1
                ),
                Achievement(
                    title: "Big Spender",
                    description: "Make a transaction over $1,000",
                    iconName: "creditcard.fill",
                    targetValue: 1000
                )
            ]
        }
    }
    
    private func checkAchievements() {
        let transactionCount = transactions.count
        let absBalance = abs(currentBalance)
        let calendar = Calendar.current
        
        // Calculate streak
        let sortedDates = transactions.map { calendar.startOfDay(for: $0.date) }.sorted(by: >)
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: currentDate) || calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate) {
                if calendar.isDate(date, inSameDayAs: currentDate) {
                    streak += 1
                } else {
                    streak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                }
            } else {
                break
            }
        }
        
        // Check perfect week (7 consecutive days with transactions)
        var perfectWeekDays = 0
        var checkDate = calendar.startOfDay(for: Date())
        for i in 0..<7 {
            let dayTransactions = transactions.filter { calendar.isDate($0.date, inSameDayAs: checkDate) }
            if !dayTransactions.isEmpty {
                perfectWeekDays += 1
            }
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        // Check saver (income > expense in current month)
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        let monthTransactions = transactions.filter { $0.date >= monthStart }
        let monthIncome = monthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let monthExpense = monthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        let isSaver = monthIncome > monthExpense && monthIncome > 0
        
        // Check big spender
        let maxTransaction = transactions.map { abs($0.amount) }.max() ?? 0
        
        for index in achievements.indices {
            var achievement = achievements[index]
            
            // Update progress based on achievement type
            if achievement.title == "First Steps" {
                achievement.progress = min(Double(transactionCount) / achievement.targetValue, 1.0)
                if transactionCount >= Int(achievement.targetValue) && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            } else if achievement.title == "Getting Started" {
                achievement.progress = min(Double(transactionCount) / achievement.targetValue, 1.0)
                if transactionCount >= Int(achievement.targetValue) && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            } else if achievement.title == "Regular User" {
                achievement.progress = min(Double(transactionCount) / achievement.targetValue, 1.0)
                if transactionCount >= Int(achievement.targetValue) && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            } else if achievement.title == "Power User" {
                achievement.progress = min(Double(transactionCount) / achievement.targetValue, 1.0)
                if transactionCount >= Int(achievement.targetValue) && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            } else if achievement.title == "Thousandaire" {
                achievement.progress = min(absBalance / achievement.targetValue, 1.0)
                if absBalance >= achievement.targetValue && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            } else if achievement.title == "Ten Thousandaire" {
                achievement.progress = min(absBalance / achievement.targetValue, 1.0)
                if absBalance >= achievement.targetValue && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            } else if achievement.title == "In the Green" {
                achievement.progress = currentBalance > 0 ? 1.0 : 0.0
                if currentBalance > 0 && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            } else if achievement.title == "Week Warrior" {
                achievement.progress = min(Double(streak) / achievement.targetValue, 1.0)
                if streak >= Int(achievement.targetValue) && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            } else if achievement.title == "Month Master" {
                achievement.progress = min(Double(streak) / achievement.targetValue, 1.0)
                if streak >= Int(achievement.targetValue) && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            } else if achievement.title == "Perfect Week" {
                achievement.progress = min(Double(perfectWeekDays) / achievement.targetValue, 1.0)
                if perfectWeekDays >= Int(achievement.targetValue) && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            } else if achievement.title == "Saver" {
                achievement.progress = isSaver ? 1.0 : 0.0
                if isSaver && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            } else if achievement.title == "Big Spender" {
                achievement.progress = min(maxTransaction / achievement.targetValue, 1.0)
                if maxTransaction >= achievement.targetValue && !achievement.isUnlocked {
                    achievement.isUnlocked = true
                    achievement.unlockedDate = Date()
                }
            }
            
            achievements[index] = achievement
        }
        
        saveData()
    }
    
    // MARK: - Persistence
    
    func saveData() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: "transactions")
        }
        UserDefaults.standard.set(currentBalance, forKey: "currentBalance")
        if let encoded = try? JSONEncoder().encode(alertRules) {
            UserDefaults.standard.set(encoded, forKey: "alertRules")
        }
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: "achievements")
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "transactions"),
           let decoded = try? JSONDecoder().decode([FinancialTransaction].self, from: data) {
            transactions = decoded
        }
        
        if UserDefaults.standard.object(forKey: "currentBalance") != nil {
            currentBalance = UserDefaults.standard.double(forKey: "currentBalance")
        } else {
            // Calculate initial balance from transactions
            currentBalance = transactions.reduce(0) { balance, transaction in
                balance + (transaction.type == .income ? transaction.amount : -transaction.amount)
            }
        }
        
        if let data = UserDefaults.standard.data(forKey: "alertRules"),
           let decoded = try? JSONDecoder().decode([AlertRule].self, from: data) {
            alertRules = decoded
        } else {
            initializeDefaultAlerts()
        }
        
        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            initializeAchievements()
        }
        
        updateStatistics()
        updateDailyFlows()
        detectPatterns()
        checkAchievements()
    }
}

