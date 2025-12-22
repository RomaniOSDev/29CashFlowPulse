//
//  ContentView.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CashFlowViewModel()
    @State private var selectedTab = 0
    @State private var showQuickAdd = false
    @State private var quickAddType: TransactionType = .income
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                MainPulseView(viewModel: viewModel)
                    .tag(0)
                    .tabItem {
                        Image(systemName: "waveform.circle.fill")
                        Text("Pulse")
                    }
                
                DailyFlowView(viewModel: viewModel)
                    .tag(1)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Daily")
                    }
                
                PatternsView(viewModel: viewModel)
                    .tag(2)
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Patterns")
                    }
                
                AlertsView(viewModel: viewModel)
                    .tag(3)
                    .tabItem {
                        Image(systemName: "bell.fill")
                        Text("Alerts")
                    }
                
                AchievementsView(viewModel: viewModel)
                    .tag(4)
                    .tabItem {
                        Image(systemName: "trophy.fill")
                        Text("Achievements")
                    }
                
                SettingsView(viewModel: viewModel)
                    .tag(5)
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
            }
            .accentColor(.appAccentPrimary)
            
            // Quick Add Overlay
            if showQuickAdd {
                QuickAddView(
                    viewModel: viewModel,
                    transactionType: quickAddType,
                    isPresented: $showQuickAdd
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onAppear {
            setupTabBarAppearance()
            checkOnboardingStatus()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.cardBackground)
        appearance.shadowColor = .clear
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func checkOnboardingStatus() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompletedOnboarding {
            showOnboarding = true
        }
    }
}

#Preview {
    ContentView()
}

