//
//  AlertRule.swift
//  29CashFlowPulse
//
//  Created by Роман Главацкий on 16.12.2025.
//

import Foundation

struct AlertRule: Identifiable, Codable {
    let id: UUID
    var name: String
    var condition: AlertCondition
    var isEnabled: Bool
    var triggerCount: Int = 0
    
    init(
        id: UUID = UUID(),
        name: String,
        condition: AlertCondition,
        isEnabled: Bool = true,
        triggerCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.condition = condition
        self.isEnabled = isEnabled
        self.triggerCount = triggerCount
    }
}


