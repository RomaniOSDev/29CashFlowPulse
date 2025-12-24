//
//  MainPulseView.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import SwiftUI

struct MainPulseView: View {
    @ObservedObject var viewModel: CashFlowViewModel
    @State private var pulseScale: CGFloat = 1.0
    @State private var showQuickAdd = false
    @State private var quickAddType: TransactionType = .income
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.appBackground
                    .ignoresSafeArea()
                
                // Background pulses
                ForEach(viewModel.activePulses) { pulse in
                    PulseView(pulse: pulse)
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Top spacing
                        Spacer()
                            .frame(height: max(20, geometry.size.height * 0.05))
                        
                        // Current Balance
                        VStack(spacing: 8) {
                            Text("Balance")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                            
                            Text(formatCurrency(viewModel.currentBalance))
                                .font(.system(size: min(56, geometry.size.width * 0.12), weight: .bold, design: .rounded))
                                .foregroundColor(.appAccentPrimary)
                                .minimumScaleFactor(0.3)
                                .lineLimit(1)
                                .padding(.horizontal, 20)
                        }
                        .padding(.bottom, max(20, geometry.size.height * 0.03))
                        
                        // Central Pulse Sphere
                        ZStack {
                            // Outer pulse rings
                            ForEach(0..<3) { index in
                                Circle()
                                    .stroke(
                                        pulseColor.opacity(0.3 - Double(index) * 0.1),
                                        lineWidth: 2
                                    )
                                    .frame(width: min(200, geometry.size.width * 0.4), height: min(200, geometry.size.width * 0.4))
                                    .scaleEffect(pulseScale + CGFloat(index) * 0.2)
                                    .opacity(pulseScale > 1.0 ? 1.0 - Double(index) * 0.3 : 0)
                            }
                            
                            // Main sphere
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [pulseColor.opacity(0.6), pulseColor.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: min(150, geometry.size.width * 0.3), height: min(150, geometry.size.width * 0.3))
                                .shadow(color: pulseColor.opacity(0.5), radius: 20)
                        }
                        .padding(.bottom, max(20, geometry.size.height * 0.03))
                        .onAppear {
                            withAnimation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true)
                            ) {
                                pulseScale = 1.2
                            }
                        }
                        
                        // Quick Action Buttons
                        HStack(spacing: 20) {
                            QuickActionButton(
                                title: "+ Income",
                                color: .incomeColor,
                                icon: "plus.circle.fill"
                            ) {
                                quickAddType = .income
                                showQuickAdd = true
                            }
                            
                            QuickActionButton(
                                title: "- Expense",
                                color: .expenseColor,
                                icon: "minus.circle.fill"
                            ) {
                                quickAddType = .expense
                                showQuickAdd = true
                            }
                        }
                        .padding(.horizontal, max(40, geometry.size.width * 0.1))
                        .padding(.bottom, max(20, geometry.size.height * 0.03))
                        
                        // Statistics Cards
                        VStack(spacing: 16) {
                            StatisticRow(
                                period: "Today",
                                income: viewModel.todayIncome,
                                expense: viewModel.todayExpense
                            )
                            
                            StatisticRow(
                                period: "Week",
                                income: viewModel.weekIncome,
                                expense: viewModel.weekExpense
                            )
                            
                            StatisticRow(
                                period: "Month",
                                income: viewModel.monthIncome,
                                expense: viewModel.monthExpense
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .sheet(isPresented: $showQuickAdd) {
            QuickAddView(
                viewModel: viewModel,
                transactionType: quickAddType,
                isPresented: $showQuickAdd
            )
        }
    }
    
    private var pulseColor: Color {
        if viewModel.currentBalance >= 0 {
            return .incomeColor
        } else {
            return .expenseColor
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let absAmount = abs(amount)
        let sign = amount < 0 ? "-" : ""
        
        if absAmount >= 1_000_000 {
            let millions = absAmount / 1_000_000
            return String(format: "%@$%.1fM", sign, millions)
        } else if absAmount >= 1_000 {
            let thousands = absAmount / 1_000
            return String(format: "%@$%.1fK", sign, thousands)
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: amount)) ?? "$0"
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let color: Color
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.appBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .cornerRadius(16)
        }
    }
}

struct StatisticRow: View {
    let period: String
    let income: Double
    let expense: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Text(period)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextSecondary)
                .frame(minWidth: 60, alignment: .leading)
                .lineLimit(1)
            
            Spacer()
            
            HStack(spacing: 20) {
                StatisticItem(
                    label: "Income",
                    amount: income,
                    color: .incomeColor
                )
                
                StatisticItem(
                    label: "Expense",
                    amount: expense,
                    color: .expenseColor
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct StatisticItem: View {
    let label: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.appTextSecondary)
                .lineLimit(1)
            
            Text(formatAmount(amount))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(minWidth: 60)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}

struct PulseView: View {
    let pulse: FinancialPulse
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Circle()
            .fill(pulse.color.opacity(0.3))
            .frame(width: 50 * pulse.intensity, height: 50 * pulse.intensity)
            .position(pulse.position)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: pulse.lifetime)
                        .repeatCount(1, autoreverses: false)
                ) {
                    scale = 3.0
                    opacity = 0
                }
            }
    }
}

#Preview {
    MainPulseView(viewModel: CashFlowViewModel())
        .background(Color.appBackground)
}

