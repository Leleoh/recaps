//
//  ProfileViewModel.swift
//  recaps
//
//  Created by Ana Poletto on 02/12/25.
//

import Foundation
import SwiftUI

@Observable
class ProfileViewModel: ProfileViewModelProtocol {
    private let userService: UserServiceProtocol
    private let capsuleService: CapsuleServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    init(capsuleService: CapsuleServiceProtocol = CapsuleService(), userService: UserServiceProtocol = UserService(), notificationService: NotificationServiceProtocol = NotificationService.shared) {
        self.capsuleService = capsuleService
        self.userService = userService
        self.notificationService = notificationService
    }
    
    var user: User? = nil
    var allowNotifications = false
    var showSettingsAlert = false
    
    func checkNotificationStatus() async {
        let status = await notificationService.checkAuthorizationStatus()
        
        await MainActor.run {
            self.allowNotifications = (status == .authorized)
        }
    }
    
    func toggleNotifications(isOn: Bool) async {
        if isOn {
            let status = await notificationService.checkAuthorizationStatus()
            
            switch status {
            case .notDetermined:
                // Primeira vez: pede permissão
                do {
                    let granted = try await notificationService.requestAuthorization()
                    await MainActor.run { self.allowNotifications = granted }
                } catch {
                    print("Erro: \(error)")
                    await MainActor.run { self.allowNotifications = false }
                }
                
            case .denied:
                // Já negado: avisa a View para mostrar alerta/botão de configurações
                await MainActor.run {
                    self.allowNotifications = false
                    self.showSettingsAlert = true
                }
                
            case .authorized, .provisional, .ephemeral:
                await MainActor.run { self.allowNotifications = true }
                
            @unknown default:
                break
            }
        } else {
            // Usuário quer desligar. Como não podemos revogar via código,
            // também sugerimos ir às configurações.
            await MainActor.run {
                self.showSettingsAlert = true
                // Revertemos o toggle visualmente até ele mudar lá fora
                self.allowNotifications = true
            }
        }
    }
    
    func loadUser() async {
        do {
            let fetched = try await userService.getCurrentUser()
            self.user = fetched
        } catch {
            print("Erro ao carregar usuário:", error)
        }
    }
    
    var userName: String {
        user?.name ?? " "
    }
    var userEmail: String {
        user?.email ?? " "
    }
    
    func logout() {
        userService.logout()
        user = nil
    }
    
    func removeUserFromAllCapsules() async {
        guard let user = user else { return }
        do {
            let capsulesWithUser = try await capsuleService.fetchCapsules(IDs: user.capsules)
            
            for var capsule in capsulesWithUser {
                capsule.members.removeAll { $0 == user.id }
                try await capsuleService.updateCapsule(capsule: capsule)
            }
            _ = try await capsuleService.fetchCapsules(IDs: user.capsules)
            
            
        } catch {
            print("Erro ao remover usuário das cápsulas: \(error)")
        }
    }

    func deleteAccount() async {
        do {
            await removeUserFromAllCapsules()
            try await userService.deleteUser()
            user = nil
        } catch {
            print("Erro ao deletar usuário")
        }
    }
}
