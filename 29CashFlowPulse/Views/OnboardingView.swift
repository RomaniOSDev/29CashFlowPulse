//
//  OnboardingView.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index == currentPage ? Color.appAccentPrimary : Color.appTextSecondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Pages
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        icon: "waveform.circle.fill",
                        title: "Track Your Cash Flow",
                        description: "Visualize your daily financial flows through pulsing animations and a minimalist interface.",
                        color: .incomeColor
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        icon: "bolt.fill",
                        title: "Quick & Easy",
                        description: "Add transactions in 3 taps or less. Fast entry with smart category suggestions.",
                        color: .appAccentPrimary
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        icon: "chart.bar.fill",
                        title: "Discover Patterns",
                        description: "Automatically detect spending patterns, recurring payments, and unusual transactions.",
                        color: .expenseColor
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Previous")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appTextSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.cardBackground)
                                .cornerRadius(16)
                        }
                    } else {
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentPage < 2 ? "Next" : "Get Started")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appAccentPrimary)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isPresented = false
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon with pulse animation
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(1.2)
                    .opacity(0.5)
                
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundColor(color)
            }
            .padding(.bottom, 20)
            
            // Text Content
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}

