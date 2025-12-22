//
//  AchievementsView.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var viewModel: CashFlowViewModel
    
    private var unlockedAchievements: [Achievement] {
        viewModel.achievements.filter { $0.isUnlocked }
    }
    
    private var lockedAchievements: [Achievement] {
        viewModel.achievements.filter { !$0.isUnlocked }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Achievements")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    Text("\(unlockedAchievements.count) of \(viewModel.achievements.count) unlocked")
                        .font(.system(size: 14))
                        .foregroundColor(.appTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Progress Overview
                AchievementProgressView(
                    unlocked: unlockedAchievements.count,
                    total: viewModel.achievements.count
                )
                .padding(.horizontal, 20)
                
                // Unlocked Achievements
                if !unlockedAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Unlocked")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                            .padding(.horizontal, 20)
                        
                        ForEach(unlockedAchievements) { achievement in
                            AchievementCard(achievement: achievement, isUnlocked: true)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Locked Achievements
                if !lockedAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Locked")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.appTextSecondary)
                            .padding(.horizontal, 20)
                        
                        ForEach(lockedAchievements) { achievement in
                            AchievementCard(achievement: achievement, isUnlocked: false)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .background(Color.appBackground)
    }
}

struct AchievementProgressView: View {
    let unlocked: Int
    let total: Int
    
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(unlocked) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.cardBackground, lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.appAccentPrimary, .incomeColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)
                
                // Percentage text
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appAccentPrimary)
                    
                    Text("\(unlocked)/\(total)")
                        .font(.system(size: 12))
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.appAccentPrimary.opacity(0.2) : Color.cardBackground)
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? .appAccentPrimary : .appTextSecondary.opacity(0.5))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(achievement.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isUnlocked ? .appTextPrimary : .appTextSecondary)
                
                Text(achievement.description)
                    .font(.system(size: 14))
                    .foregroundColor(.appTextSecondary)
                
                // Progress bar for locked achievements
                if !isUnlocked && achievement.progress > 0 {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.cardBackground)
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appAccentPrimary)
                                .frame(width: geometry.size.width * achievement.progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.top, 4)
                }
                
                // Unlocked date
                if isUnlocked, let date = achievement.unlockedDate {
                    Text("Unlocked \(formatDate(date))")
                        .font(.system(size: 12))
                        .foregroundColor(.appAccentPrimary.opacity(0.7))
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Checkmark or lock icon
            Image(systemName: isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                .font(.system(size: 24))
                .foregroundColor(isUnlocked ? .incomeColor : .appTextSecondary.opacity(0.5))
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    AchievementsView(viewModel: CashFlowViewModel())
}


