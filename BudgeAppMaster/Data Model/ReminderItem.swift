//
//  ReminderItem.swift
//  Budget App
//
//  Created by Aaron Orr on 2/25/19.
//  Copyright © 2019 Icecream. All rights reserved.
//

import Foundation

class ReminderItem: Codable {
    var name: String = ""
    var amount: Double = 0.0
    var date: Int = 0
    var done: Bool = false
    var linkedBudget: String = ""
    var reminderRepeat: Bool = true
    var notificationSetting: Bool = false
    var notificationID: Int = 0
    
}
