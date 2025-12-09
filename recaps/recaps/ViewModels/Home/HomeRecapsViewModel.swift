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
    
    var isLoading: Bool = false
    var showCreateCapsule: Bool = false
    var showPopup = false
    var showJoinPopup = false
    var showProfile = false
    var inviteCode: String = ""
    var joinErrorMessage: String? = nil
    
    var inProgressCapsules: [Capsule] = []
    var completedCapsules: [Capsule] = []
    var user: User = User(
        id: "",
        name: "",
        email: "",
        capsules: [],
        openCapsules: []
    )

    
    private let capsuleService: CapsuleServiceProtocol
    private let userService: UserServiceProtocol
    
    init(capsuleService: CapsuleServiceProtocol = CapsuleService(), userService: UserServiceProtocol = UserService()) {
        self.capsuleService = capsuleService
        self.userService = userService
    }
    
    // MARK: - Fetch Data Logic
    @MainActor
    func fetchCapsules() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let currentUser = try await userService.getCurrentUser()
            let progressCapsuleIDs = currentUser.capsules
            let openCapsuleIDs = currentUser.openCapsules
            let capsuleIDs = progressCapsuleIDs + openCapsuleIDs

            guard !capsuleIDs.isEmpty else {
                inProgressCapsules = []
                completedCapsules = []
                return
            }

            var allCapsules = try await capsuleService
                .fetchCapsules(IDs: capsuleIDs)
                .sorted(by: { $0.createdAt < $1.createdAt })

            self.inProgressCapsules = allCapsules.filter { $0.status == .inProgress }
            self.completedCapsules = allCapsules.filter { $0.status == .completed || $0.status == .opened }

            await checkIfCapsuleIsValidOffensive(user: currentUser)

            // Recarrega depois das possíveis atualizações
            allCapsules = try await capsuleService
                .fetchCapsules(IDs: capsuleIDs)
                .sorted(by: { $0.createdAt < $1.createdAt })

            self.inProgressCapsules = allCapsules.filter { $0.status == .inProgress }
            self.completedCapsules = allCapsules.filter { $0.status == .completed || $0.status == .opened }

        } catch {
            print("Erro ao carregar dados da Home: \(error.localizedDescription)")
            inProgressCapsules = []
            completedCapsules = []
        }
    }
    
    @MainActor
    func fetchUser() async {
        do {
            let user = try await userService.getCurrentUser()
            self.user = user
        } catch {
            print("Erro ao buscar usuário: \(error)")
        }
    }
    
    //MARK: Valid Streak
    func checkIfCapsuleIsValidOffensive(user: User) async {
        print("Verificando a validades das vidas")
        
       // var updatesMade: Bool = false
        
        for capsule in user.capsules {
            do{
                let isValid = try await capsuleService.checkIfCapsuleIsValidOffensive(capsuleID: capsule)
                
                if !isValid{
                    //updatesMade = true
                    print("AVISO: Cápsula \(capsule) sofreu penalidade (vida ou reset).")
                }
            }
            catch{
                print("Erro ao verificar ofensiva da cápsula \(capsule): \(error)")
            }
        }
    }
        
//        if updatesMade {
//            print("🔄 Recarregando cápsulas para atualizar UI...")
//            await fetchCapsules()
//        } else {
//            print("✅ Nenhuma alteração necessária nas ofensivas.")
//        }
        
    func fetchCapsule(id: UUID) async -> Capsule? {
        do {
            return try await capsuleService.fetchCapsule(id: id)
        } catch {
            print("Erro ao buscar cápsula: \(error)")
            return nil
        }
    }
    
    func didTapNewRecap() {
        showCreateCapsule = true
    }
    
    func joinCapsule(code: String) async -> Capsule? {
        do {
            joinErrorMessage = nil
            print("Buscando cápsula com código: \(code)")
            
            let allCapsules = try await capsuleService.fetchAllCapsulesWithoutSubmissions()
            var user = try await userService.getCurrentUser()
            
            guard var capsule = allCapsules.first(where: { $0.code == code }) else {
                joinErrorMessage = "NotFound"
                return nil
            }
            
            if capsule.members.contains(user.id) {
                joinErrorMessage = "AlreadyMember"
                return nil
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
                capsules: user.capsules,
                openCapsules: user.openCapsules
            )
            
            print("✅ Sucesso! Entrou na cápsula: \(capsule.name)")
            
            return capsule
            
        } catch {
            joinErrorMessage = "Unknown"
            print("❌ Erro ao entrar na cápsula: \(error)")
        }
        return nil
    }
    
    func leaveCapsule(capsule: Capsule) async {
        do {
            var user = try await userService.getCurrentUser()
            
            user.capsules.removeAll(where: { $0 == capsule.id })

            var updatedCapsule = capsule
            updatedCapsule.members.removeAll(where: { $0 == user.id })

            try await capsuleService.updateCapsule(capsule: updatedCapsule)

            _ = try await userService.updateUser(
                user,
                name: user.name,
                email: user.email,
                capsules: user.capsules,
                openCapsules: user.openCapsules
            )

            await fetchCapsules()

        } catch {
            print("Erro ao apagar cápsula: \(error.localizedDescription)")
        }
    }
    
    func updateUserTest() async throws {
        let user = User(id: userService.getUserId(), name: "Leonel Maluco", email: "leonel@maluco.verme", capsules: [], openCapsules: [UUID()])
        
        do {
            let _ = try await userService.updateUser(user, name: nil, email: nil, capsules: nil, openCapsules: [UUID()])
            print("deu  bom")
        } catch {
            print("deu merda aqui")
        }
            
    }
     
}

