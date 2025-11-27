//
//  CreatingCapsuleTestViewModel.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 24/11/25.
//

import Foundation
import SwiftUI

@Observable
class HomeRecapsViewModel: HomeRecapsViewModelProtocol {
    
    var showCreateCapsule: Bool = false
    var showPopup = false
    var showJoinPopup = false
    var inviteCode: String = ""
    var joinErrorMessage: String? = nil
    
    private let capsuleService: CapsuleServiceProtocol
    private let userService: UserServiceProtocol
    
    init(capsuleService: CapsuleServiceProtocol = CapsuleService(), userService: UserServiceProtocol = UserService()) {
        self.capsuleService = capsuleService
        self.userService = userService
    }
    
    func didTapNewRecap() {
        showCreateCapsule = true
    }
    
    func joinCapsule(code: String) async {
        do {
            joinErrorMessage = nil
            print("Buscando cápsula com código: \(code)")
            
            let allCapsules = try await capsuleService.fetchAllCapsulesWithoutSubmissions()
            var user = try await userService.getCurrentUser()
            
            guard var capsule = allCapsules.first(where: { $0.code == code }) else {
                joinErrorMessage = "NotFound"
                return
            }
            
            if capsule.members.contains(user.id) {
                joinErrorMessage = "AlreadyMember"
                return
            }
            
            // Adiciona usuário à cápsula e atualiza
            capsule.members.append(user.id)
            try await capsuleService.updateCapsule(capsule: capsule)
            
            // Adiciona cápsula ao usuário e atualiza
            user.capsules.append(capsule.id)
            _ = try await userService.updateUser(
                user,
                name: user.name,
                email: user.email,
                capsules: user.capsules
            )
            
            print("✅ Sucesso! Entrou na cápsula: \(capsule.name)")
            
            // Aqui você poderia disparar um refresh da lista da Home
            
        } catch {
            joinErrorMessage = "Unknown"
            print("❌ Erro ao entrar na cápsula: \(error)")
        }
    }
}
