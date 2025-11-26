//
//  CreatingCapsuleTestViewModel.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 24/11/25.
//

import SwiftUI
import AuthenticationServices
import CloudKit

@Observable
class CreatingCapsuleTestViewModel {
    private let userService = UserService()
    private let capsuleService = CapsuleService()
    
    func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<8).map { _ in chars.randomElement()! })
    }
    
    func creatingCapsule(code: String, name: String, offensiveTarget: Int) async {
        do {
            let capsule = Capsule(
                id: UUID(),
                code: code,
                submissions: [],
                name: name,
                createdAt: Date(),
                offensive: 0,
                offensiveTarget: offensiveTarget,
                lastSubmissionDate: Date(),
                validOffensive: true,
                lives: 3,
                members: [userService.getUserId()],
                ownerId: userService.getUserId(),
                status: .inProgress
            )
            
            print("AAAA >>> Criando cápsula")

            let newCapsuleID = try await capsuleService.createCapsule(capsule: capsule)

            var currentUser = try await userService.getCurrentUser()
            currentUser.capsules.append(newCapsuleID)

            try await userService.updateUser(
                currentUser,
                capsules: currentUser.capsules
            )

            print("Capsule", capsule)
            print("User", currentUser)

        } catch {
            print("Erro ao criar a Capsula", error)
        }
    }

    
    func joinCapsule(code: String) async throws {
        print("entro no join")
        let allCapsules = try await capsuleService.fetchAllCapsules()
        
        print("todas as capsulas")
        var user = try await userService.getCurrentUser()
        print(user.capsules)
        print(" ")
        print(user)
        
        guard var capsule = allCapsules.first(where: { $0.code == code }) else {
            print("Nenhuma cápsula encontrada com esse código.")
            return
        }

        // 4. Verificar se usuário já está na cápsula
        if capsule.members.contains(user.id) {
            print("Usuário já é membro desta cápsula.")
        }

        // 5. Verificar se cápsula já está na lista do usuário
        if user.capsules.contains(capsule.id) {
            print("Cápsula já está na lista do usuário.")
        }

        // 6. Adiciona usuário à cápsula
        capsule.members.append(user.id)
        try await capsuleService.updateCapsule(capsule: capsule)

        // 7. Adiciona cápsula ao usuário
        user.capsules.append(capsule.id)
        _ = try await userService.updateUser(user, capsules: user.capsules)

        // --- LOG FINAL ---
        print("Usuário entrou na cápsula:", capsule.code)
        print("User:", user)
        print("Capsule:", capsule)
    }


}
