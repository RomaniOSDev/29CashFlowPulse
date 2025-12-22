//
//  SettingsView.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var viewModel: CashFlowViewModel
    @Environment(\.openURL) var openURL
    @State private var showClearDataAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Settings Sections
                VStack(spacing: 16) {
                    // App Info Section
                    SettingsSection(title: "App") {
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "Version",
                            value: "1.0.0",
                            showChevron: false
                        )
                    }
                    
                    // Legal Section
                    SettingsSection(title: "Legal") {
                        SettingsRow(
                            icon: "hand.raised.fill",
                            title: "Privacy Policy",
                            showChevron: true
                        ) {
                            openURL(URL(string: "https://www.termsfeed.com/live/d09ef66c-75ba-48a2-aa6b-0e7b1f96897b")!)
                        }
                        
                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Terms of Service",
                            showChevron: true
                        ) {
                            openURL(URL(string: "https://www.termsfeed.com/live/8bda1005-c71f-46dd-bc34-ff036c6f4f19")!)
                        }
                    }
                    
                    // Support Section
                    SettingsSection(title: "Support") {
                        SettingsRow(
                            icon: "star.fill",
                            title: "Rate Us",
                            showChevron: true
                        ) {
                            rateApp()
                        }
                        
                        SettingsRow(
                            icon: "envelope.fill",
                            title: "Contact Us",
                            showChevron: true
                        ) {
                            if let url = URL(string: "mailto:support@cashflowpulse.app") {
                                openURL(url)
                            }
                        }
                    }
                    
                    // Data Section
                    SettingsSection(title: "Data") {
                        SettingsRow(
                            icon: "trash.fill",
                            title: "Clear All Data",
                            titleColor: .expenseColor,
                            showChevron: false
                        ) {
                            showClearDataAlert = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.appBackground)
        .alert("Clear All Data", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will delete all your transactions, achievements, and settings. This action cannot be undone.")
        }
    }
    
    private func clearAllData() {
        viewModel.transactions.removeAll()
        viewModel.currentBalance = 0.0
        viewModel.achievements.removeAll()
        viewModel.alertRules.removeAll()
        viewModel.initializeAchievements()
        viewModel.initializeDefaultAlerts()
        viewModel.saveData()
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "transactions")
        UserDefaults.standard.removeObject(forKey: "currentBalance")
        UserDefaults.standard.removeObject(forKey: "achievements")
        UserDefaults.standard.removeObject(forKey: "alertRules")
    }
    
    private func rateApp() {
        SKStoreReviewController.requestReview()
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appTextSecondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var titleColor: Color = .appTextPrimary
    let showChevron: Bool
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        value: String? = nil,
        titleColor: Color = .appTextPrimary,
        showChevron: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.titleColor = titleColor
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.appAccentPrimary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(titleColor)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.appTextSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
        
        if showChevron {
            Divider()
                .background(Color.appBackground.opacity(0.3))
                .padding(.leading, 56)
        }
    }
}

#Preview {
    SettingsView(viewModel: CashFlowViewModel())
}

