//
//  PatternsView.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import SwiftUI

struct PatternsView: View {
    @ObservedObject var viewModel: CashFlowViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Spending Patterns")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    Text("Detected patterns in your transactions")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                if viewModel.spendingPatterns.isEmpty {
                    EmptyPatternsView()
                        .padding(.top, 100)
                } else {
                    // Pattern Clusters
                    ForEach(viewModel.spendingPatterns) { pattern in
                        PatternClusterCard(pattern: pattern, viewModel: viewModel)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Category Breakdown
                CategoryBreakdownView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .background(Color.appBackground)
    }
}

struct PatternClusterCard: View {
    let pattern: SpendingPattern
    @ObservedObject var viewModel: CashFlowViewModel
    @State private var pulseScale: CGFloat = 1.0
    
    private var categoryTransactions: [FinancialTransaction] {
        viewModel.transactions.filter { $0.category == pattern.category }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Category Icon with Pulse
                ZStack {
                    Circle()
                        .fill(pattern.category.isIncome ? Color.incomeColor.opacity(0.2) : Color.expenseColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .stroke(pattern.category.isIncome ? Color.incomeColor : Color.expenseColor, lineWidth: 2)
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulseScale)
                        .opacity(2.0 - pulseScale)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(pattern.category.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                    
                    Text(pattern.frequency.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatAmount(pattern.averageAmount))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(pattern.category.isIncome ? .incomeColor : .expenseColor)
                    
                    Text("avg")
                        .font(.system(size: 10))
                        .foregroundColor(.appTextSecondary)
                }
            }
            
            // Pattern Visualization
            HStack(spacing: 4) {
                ForEach(0..<min(categoryTransactions.count, 20), id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(pattern.category.isIncome ? Color.incomeColor : Color.expenseColor)
                        .frame(height: 30)
                        .opacity(Double(index) / Double(min(categoryTransactions.count, 20)) * 0.5 + 0.5)
                }
            }
            
            // Last Occurrence
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)
                
                Text("Last: \(formatDate(pattern.lastOccurrence))")
                    .font(.system(size: 12))
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.3
            }
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct CategoryBreakdownView: View {
    @ObservedObject var viewModel: CashFlowViewModel
    
    private var categoryTotals: [(category: TransactionCategory, total: Double)] {
        var totals: [TransactionCategory: Double] = [:]
        
        for transaction in viewModel.transactions {
            totals[transaction.category, default: 0] += transaction.amount
        }
        
        return totals.map { (category: $0.key, total: $0.value) }
            .sorted { abs($0.total) > abs($1.total) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appTextPrimary)
            
            if categoryTotals.isEmpty {
                Text("No transactions yet")
                    .font(.system(size: 14))
                    .foregroundColor(.appTextSecondary)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(categoryTotals.prefix(10), id: \.category) { item in
                        CategoryBreakdownRow(category: item.category, total: item.total)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct CategoryBreakdownRow: View {
    let category: TransactionCategory
    let total: Double
    
    private var maxTotal: Double {
        // This would ideally come from viewModel, but for simplicity we'll use a fixed value
        10000
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                Text(formatAmount(total))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(category.isIncome ? .incomeColor : .expenseColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.cardBackground.opacity(0.5))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(category.isIncome ? Color.incomeColor : Color.expenseColor)
                        .frame(width: geometry.size.width * min(abs(total) / maxTotal, 1.0), height: 6)
                }
            }
            .frame(height: 6)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        let sign = category.isIncome ? "+" : "-"
        return sign + (formatter.string(from: NSNumber(value: abs(amount))) ?? "$0")
    }
}

struct EmptyPatternsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.appTextSecondary)
            
            Text("No patterns detected")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.appTextSecondary)
            
            Text("Add more transactions to detect patterns")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary.opacity(0.7))
        }
    }
}

#Preview {
    PatternsView(viewModel: CashFlowViewModel())
}



