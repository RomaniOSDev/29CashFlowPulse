//
//  QuickAddView.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import SwiftUI

struct QuickAddView: View {
    @ObservedObject var viewModel: CashFlowViewModel
    let transactionType: TransactionType
    @Binding var isPresented: Bool
    
    @State private var amount: String = ""
    @State private var selectedCategory: TransactionCategory?
    @State private var description: String = ""
    @State private var showCategoryPicker = false
    
    private var categories: [TransactionCategory] {
        transactionType == .income ? TransactionCategory.incomeCategories : TransactionCategory.expenseCategories
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.appTextSecondary)
                    
                    Spacer()
                    
                    Text(transactionType == .income ? "Add Income" : "Add Expense")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveTransaction()
                    }
                    .foregroundColor(.appAccentPrimary)
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider()
                    .background(Color.cardBackground)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Amount Display
                        VStack(spacing: 12) {
                            Text("Amount")
                                .font(.system(size: 14))
                                .foregroundColor(.appTextSecondary)
                            
                            Text(formatAmount())
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(transactionType == .income ? .incomeColor : .expenseColor)
                                .frame(height: 80)
                        }
                        .padding(.top, 40)
                        
                        // Category Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 14))
                                .foregroundColor(.appTextSecondary)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(categories, id: \.self) { category in
                                        CategoryButton(
                                            category: category,
                                            isSelected: selectedCategory == category
                                        ) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Description (Optional)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description (Optional)")
                                .font(.system(size: 14))
                                .foregroundColor(.appTextSecondary)
                                .padding(.horizontal, 20)
                            
                            TextField("Add note...", text: $description)
                                .font(.system(size: 16))
                                .foregroundColor(.appTextPrimary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                        }
                        
                        // Number Pad
                        VStack(spacing: 16) {
                            ForEach(0..<4) { row in
                                HStack(spacing: 16) {
                                    ForEach(0..<3) { col in
                                        let number = row * 3 + col + 1
                                        if number <= 9 {
                                            NumberButton(number: "\(number)") {
                                                appendNumber("\(number)")
                                            }
                                        } else if number == 10 {
                                            NumberButton(number: ".") {
                                                appendNumber(".")
                                            }
                                        } else if number == 11 {
                                            NumberButton(number: "0") {
                                                appendNumber("0")
                                            }
                                        } else {
                                            NumberButton(number: "⌫") {
                                                deleteLast()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
    
    private var canSave: Bool {
        guard let amountValue = Double(amount), amountValue > 0 else {
            return false
        }
        return selectedCategory != nil
    }
    
    private func formatAmount() -> String {
        if amount.isEmpty {
            return "$0"
        }
        
        if let value = Double(amount) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: value)) ?? "$0"
        }
        
        return "$\(amount)"
    }
    
    private func appendNumber(_ digit: String) {
        if digit == "." {
            if !amount.contains(".") {
                amount += digit
            }
        } else {
            amount += digit
        }
    }
    
    private func deleteLast() {
        if !amount.isEmpty {
            amount.removeLast()
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let category = selectedCategory else {
            return
        }
        
        let transaction = FinancialTransaction(
            amount: amountValue,
            type: transactionType,
            category: category,
            date: Date(),
            description: description.isEmpty ? nil : description
        )
        
        viewModel.addTransaction(transaction)
        isPresented = false
        
        // Reset form
        amount = ""
        selectedCategory = nil
        description = ""
    }
}

struct CategoryButton: View {
    let category: TransactionCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .appBackground : .appTextPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isSelected ? Color.appAccentPrimary : Color.cardBackground)
                .cornerRadius(20)
        }
    }
}

struct NumberButton: View {
    let number: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(number)
                .font(.system(size: 32, weight: .medium, design: .rounded))
                .foregroundColor(.appAccentPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(Color.cardBackground)
                .cornerRadius(16)
        }
    }
}

#Preview {
    QuickAddView(
        viewModel: CashFlowViewModel(),
        transactionType: .income,
        isPresented: .constant(true)
    )
}


