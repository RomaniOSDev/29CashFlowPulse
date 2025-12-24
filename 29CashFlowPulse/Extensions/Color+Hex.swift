//
//  Color+Hex.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let appBackground = Color(hex: "292621")
    static let appAccentPrimary = Color(hex: "F2F740")
    static let appAccentSecondary = Color(hex: "FFFFFF")
    static let appTextPrimary = Color.white.opacity(0.95)
    static let appTextSecondary = Color(hex: "B0B0B0").opacity(0.7)
    static let incomeColor = Color(hex: "00FF88")
    static let expenseColor = Color(hex: "FF4757")
    static let cardBackground = Color(hex: "3A3630")
}



