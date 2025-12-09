//
//  NotificationService.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 08/12/25.
//

import Foundation
import UserNotifications
import Combine

class NotificationService: NSObject, NotificationServiceProtocol {
    
    static let shared = NotificationService()
    
    @Published var selectedCapsuleID: String?
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleStreakReminder(for capsule: Capsule, at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🗝️ Offensive in risk!"
        content.body = "Your daily submission in the '\(capsule.name)' Recapsule is pending, save a memory to protect your streak days"
        content.sound = .default
        content.userInfo = ["capsuleId": capsule.id.uuidString]
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let requestID = "streak-\(capsule.id.uuidString)"
        
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar para \(capsule.name): \(error)")
            } else {
                print("⏰ Agendado para cápsula \(capsule.name) às \(hour):\(minute)")
            }
        }
    }
    
    func cancelReminder(for capsuleID: UUID) {
        let requestID = "streak-\(capsuleID.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestID])
        print("🔕 Lembrete cancelado para cápsula ID: \(capsuleID)")
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    
    // Mostrar notificação mesmo com app aberto
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
    
    // Tratamento de clique na notifiação
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        if let capsuleID = userInfo["capsuleId"] as? String {
            await MainActor.run {
                self.selectedCapsuleID = capsuleID
            }
        }
    }
}
