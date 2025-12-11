//
//  NotificationServiceProtocol.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 08/12/25.
//

import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestAuthorization() async throws -> Bool
    func checkAuthorizationStatus() async -> UNAuthorizationStatus
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval)
    
    func scheduleStreakReminder(for capsule: Capsule, at hour: Int, minute: Int)
    func cancelReminder(for capsuleID: UUID)
}
