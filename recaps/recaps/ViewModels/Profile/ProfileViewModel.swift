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
    
    init(capsuleService: CapsuleServiceProtocol = CapsuleService(), userService: UserServiceProtocol = UserService()) {
        self.capsuleService = capsuleService
        self.userService = userService
    }
    
    var user: User? = nil
    var allowNotifications = false
    var showDeleteAlert: Bool = false
    var showSignOutAlert: Bool = false
    
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
