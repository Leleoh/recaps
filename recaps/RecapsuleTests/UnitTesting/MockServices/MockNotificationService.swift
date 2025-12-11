//
//  MockNotificationService.swift
//  recapsTests
//
//  Created by Richard Fagundes Rodrigues on 09/12/25.
//

import Foundation
import UserNotifications
@testable import recaps

class MockNotificationService: NotificationServiceProtocol {

    // MARK: - Configurable Responses (Stubs)
    // Configure estas variáveis antes do teste para simular cenários (ex: permissão negada)
    var authorizationStatusToReturn: UNAuthorizationStatus = .authorized
    var requestAuthorizationResult: Bool = true
    var shouldThrowOnRequestAuthorization: Bool = false

    // MARK: - Trackers (Flags para verificar chamadas)
    var didRequestAuthorization = false
    var didCheckAuthorizationStatus = false
    var didScheduleNotification = false
    var didScheduleStreakReminder = false
    var didCancelReminder = false

    // MARK: - Captured Values (Para validar dados passados)
    var lastScheduledNotificationTitle: String?
    var lastScheduledNotificationBody: String?
    var lastScheduledStreakCapsule: Capsule?
    var lastScheduledStreakHour: Int?
    var lastScheduledStreakMinute: Int?
    var lastCanceledCapsuleID: UUID?

    // MARK: - Protocol Methods

    func requestAuthorization() async throws -> Bool {
        didRequestAuthorization = true
        
        if shouldThrowOnRequestAuthorization {
            throw NSError(domain: "MockNotificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro forçado no requestAuthorization"])
        }
        
        return requestAuthorizationResult
    }

    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        didCheckAuthorizationStatus = true
        return authorizationStatusToReturn
    }

    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval) {
        didScheduleNotification = true
        lastScheduledNotificationTitle = title
        lastScheduledNotificationBody = body
    }
    
    func scheduleStreakReminder(for capsule: Capsule, at hour: Int, minute: Int) {
        didScheduleStreakReminder = true
        lastScheduledStreakCapsule = capsule
        lastScheduledStreakHour = hour
        lastScheduledStreakMinute = minute
    }
    
    func cancelReminder(for capsuleID: UUID) {
        didCancelReminder = true
        lastCanceledCapsuleID = capsuleID
    }
    
    // MARK: - Helper para limpar estado entre testes
    func resetTrackers() {
        didRequestAuthorization = false
        didCheckAuthorizationStatus = false
        didScheduleNotification = false
        didScheduleStreakReminder = false
        didCancelReminder = false
        
        lastScheduledNotificationTitle = nil
        lastScheduledNotificationBody = nil
        lastScheduledStreakCapsule = nil
        lastScheduledStreakHour = nil
        lastScheduledStreakMinute = nil
        lastCanceledCapsuleID = nil
        
        // Resetar configurações padrão se desejar
        authorizationStatusToReturn = .authorized
        requestAuthorizationResult = true
        shouldThrowOnRequestAuthorization = false
    }
}
