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
class HomeRecapsViewModel {
    private let userService = UserService()
    private let capsuleService = CapsuleService()
    
    func generateCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<8).map { _ in chars.randomElement()! })
    }
    
    func creatingCapsule(code: String, name: String, offensive: Int) async {
        do {
            let capsule = Capsule(
                id: UUID(),
                code: code,
                submissions: [],
                name: name,
                createdAt: Date(),
                offensive: offensive,
                lastSubmissionDate: Date(),
                validOffensive: true,
                lives: 3,
                members: [userService.getUserId()],
                ownerId: userService.getUserId(),
                status: .inProgress
            )

            print("Criando cápsula")

            let newCapsuleID = try await capsuleService.createCapsule(capsule: capsule)

            let currentUser = try await userService.getCurrentUser()

            var userCapsules = currentUser.capsules
            userCapsules.append(newCapsuleID)

            print(capsule)
            print("Usuário:", currentUser)

            try await userService.updateUser(currentUser, capsules: userCapsules)

            let user = try await userService.getCurrentUser()
            print("User atualizado:", user)

        } catch {
            print("Erro ao criar a cápsula", error)
        }
    }

    
    
    
    func joinCapsule(code: String) async throws {
        let allCapsules = try await capsuleService.fetchAllCapsulesWithoutSubmissions()
        
        var user = try await userService.getCurrentUser()
        
        guard var capsule = allCapsules.first(where: { $0.code == code }) else {
            print("Nenhuma cápsula encontrada com esse código.")
            return
        }
        
        if capsule.members.contains(user.id) {
            print("Usuário já é membro desta cápsula.")
            return
        }
        
        if user.capsules.contains(capsule.id) {
            print("Cápsula já está na lista do usuário.")
            return
        }
        
        capsule.members.append(user.id)
        try await capsuleService.updateCapsule(capsule: capsule)
        
        user.capsules.append(capsule.id)
        _ = try await userService.updateUser(user)
        
        print("Usuário entrou na cápsula:", capsule.code)
        print("User:", user)
        print("Capsule:", capsule)
    }
    
    func getAllOpenCapsules() async throws -> [Capsule] {
        let capsulesIDs = try await userService.getCurrentUser().capsules
        let userCapsules = try await capsuleService.fetchCapsules(IDs: capsulesIDs)
        
        return userCapsules.filter { $0.status == .opened }
        
    }
    
    func getAllCloseCapsules() async throws -> [Capsule] {
        let capsulesIDs = try await userService.getCurrentUser().capsules
        let userCapsules = try await capsuleService.fetchCapsules(IDs: capsulesIDs)
        
        return userCapsules.filter { $0.status == .inProgress || $0.status == .completed }
    }
    
}
