//
//  DailyFlowView.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import SwiftUI

struct DailyFlowView: View {
    @ObservedObject var viewModel: CashFlowViewModel
    @State private var selectedDate = Date()
    @State private var selectedTransaction: FinancialTransaction?
    
    private var selectedDayTransactions: [FinancialTransaction] {
        viewModel.getTransactions(for: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Date Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.dailyFlows.prefix(30), id: \.id) { day in
                        DateButton(
                            date: day.date,
                            isSelected: Calendar.current.isDate(day.date, inSameDayAs: selectedDate),
                            netFlow: day.netFlow
                        ) {
                            selectedDate = day.date
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            .background(Color.cardBackground)
            
            // Timeline
            ScrollView {
                VStack(spacing: 0) {
                    if selectedDayTransactions.isEmpty {
                        EmptyDayView()
                            .padding(.top, 100)
                    } else {
                        ForEach(selectedDayTransactions) { transaction in
                            TransactionTimelineItem(transaction: transaction)
                                .onTapGesture {
                                    selectedTransaction = transaction
                                }
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
        .background(Color.appBackground)
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction, viewModel: viewModel)
        }
    }
}

struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let netFlow: Double
    let action: () -> Void
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(weekdayFormatter.string(from: date))
                    .font(.system(size: 10))
                    .foregroundColor(.appTextSecondary)
                
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? .appBackground : .appTextPrimary)
                
                Circle()
                    .fill(netFlow >= 0 ? Color.incomeColor : Color.expenseColor)
                    .frame(width: 6, height: 6)
                    .opacity(isSelected ? 1.0 : 0.5)
            }
            .frame(width: 50)
            .padding(.vertical, 12)
            .background(isSelected ? Color.appAccentPrimary : Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

struct TransactionTimelineItem: View {
    let transaction: FinancialTransaction
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Time
            Text(timeFormatter.string(from: transaction.date))
                .font(.system(size: 12))
                .foregroundColor(.appTextSecondary)
                .frame(width: 60, alignment: .leading)
            
            // Pulse Point
            ZStack {
                Circle()
                    .fill(transaction.pulseColor)
                    .frame(width: pulseSize, height: pulseSize)
                    .shadow(color: transaction.pulseColor.opacity(0.5), radius: 8)
                
                // Pulse animation
                Circle()
                    .stroke(transaction.pulseColor.opacity(0.3), lineWidth: 2)
                    .frame(width: pulseSize, height: pulseSize)
                    .scaleEffect(1.5)
                    .opacity(0)
                    .animation(
                        Animation.easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false),
                        value: UUID()
                    )
            }
            
            // Transaction Info
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appTextPrimary)
                
                if let description = transaction.description {
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                }
            }
            
            Spacer()
            
            // Amount
            Text(formatAmount(transaction.amount))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(transaction.pulseColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.cardBackground.opacity(0.5))
    }
    
    private var pulseSize: CGFloat {
        min(max(transaction.pulseIntensity * 20, 12), 24)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        let sign = transaction.type == .income ? "+" : "-"
        return sign + (formatter.string(from: NSNumber(value: amount)) ?? "$0")
    }
}

struct EmptyDayView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.appTextSecondary)
            
            Text("No transactions")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.appTextSecondary)
            
            Text("Add your first transaction")
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary.opacity(0.7))
        }
    }
}

struct TransactionDetailView: View {
    let transaction: FinancialTransaction
    @ObservedObject var viewModel: CashFlowViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Amount
                    Text(formatAmount(transaction.amount))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(transaction.pulseColor)
                        .padding(.top, 40)
                    
                    // Details
                    VStack(spacing: 16) {
                        DetailRow(label: "Type", value: transaction.type.rawValue)
                        DetailRow(label: "Category", value: transaction.category.rawValue)
                        DetailRow(label: "Date", value: formatDate(transaction.date))
                        
                        if let description = transaction.description {
                            DetailRow(label: "Description", value: description)
                        }
                        
                        if let location = transaction.location {
                            DetailRow(label: "Location", value: location)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Delete Button
                    Button(action: {
                        viewModel.deleteTransaction(transaction)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Delete Transaction")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.expenseColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.cardBackground)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Transaction Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appAccentPrimary)
                }
            }
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        let sign = transaction.type == .income ? "+" : "-"
        return sign + (formatter.string(from: NSNumber(value: amount)) ?? "$0")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextPrimary)
        }
    }
}

#Preview {
    DailyFlowView(viewModel: CashFlowViewModel())
}



