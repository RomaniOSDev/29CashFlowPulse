//
//  AlertsView.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import SwiftUI

struct AlertsView: View {
    @ObservedObject var viewModel: CashFlowViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Alerts")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    Text("Monitor your financial activity")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Alert Rules
                VStack(spacing: 16) {
                    ForEach(viewModel.alertRules) { rule in
                        AlertRuleCard(rule: rule, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 20)
                
                // Statistics
                AlertStatisticsView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .background(Color.appBackground)
    }
}

struct AlertRuleCard: View {
    let rule: AlertRule
    @ObservedObject var viewModel: CashFlowViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Alert Icon
                ZStack {
                    Circle()
                        .fill(rule.isEnabled ? Color.expenseColor.opacity(0.2) : Color.appTextSecondary.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: rule.isEnabled ? "bell.fill" : "bell.slash.fill")
                        .font(.system(size: 18))
                        .foregroundColor(rule.isEnabled ? .expenseColor : .appTextSecondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(rule.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                    
                    Text(rule.condition.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
                
                // Toggle
                Toggle("", isOn: Binding(
                    get: { rule.isEnabled },
                    set: { newValue in
                        if let index = viewModel.alertRules.firstIndex(where: { $0.id == rule.id }) {
                            viewModel.alertRules[index].isEnabled = newValue
                            viewModel.saveData()
                        }
                    }
                ))
                .tint(.appAccentPrimary)
            }
            
            // Trigger Count
            if rule.triggerCount > 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.expenseColor)
                    
                    Text("Triggered \(rule.triggerCount) time\(rule.triggerCount == 1 ? "" : "s")")
                        .font(.system(size: 12))
                        .foregroundColor(.expenseColor)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct AlertStatisticsView: View {
    @ObservedObject var viewModel: CashFlowViewModel
    
    private var totalTriggers: Int {
        viewModel.alertRules.reduce(0) { $0 + $1.triggerCount }
    }
    
    private var activeAlerts: Int {
        viewModel.alertRules.filter { $0.isEnabled }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appTextPrimary)
            
            HStack(spacing: 20) {
                StatisticBox(
                    title: "Active Alerts",
                    value: "\(activeAlerts)",
                    color: .appAccentPrimary
                )
                
                StatisticBox(
                    title: "Total Triggers",
                    value: "\(totalTriggers)",
                    color: .expenseColor
                )
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct StatisticBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.appBackground.opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    AlertsView(viewModel: CashFlowViewModel())
}

