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
    
    var inProgressCapsules: [Capsule] = []
    var completedCapsules: [Capsule] = []
    
    private let capsuleService: CapsuleServiceProtocol
    private let userService: UserServiceProtocol
    
    init(capsuleService: CapsuleServiceProtocol = CapsuleService(), userService: UserServiceProtocol = UserService()) {
        self.capsuleService = capsuleService
        self.userService = userService
    }
    
    // MARK: - Fetch Data Logic
    @MainActor
    func fetchCapsules() async {
        do {
            // Pega o usuário logado para acessar a lista de IDs de cápsulas
            let currentUser = try await userService.getCurrentUser()
            let capsuleIDs = currentUser.capsules
            
            guard !capsuleIDs.isEmpty else {
                print("Usuário não possui cápsulas.")
                return
            }
            
            // Busca os objetos Capsule no CloudKit usando os IDs
            var allCapsules = try await capsuleService.fetchCapsules(IDs: capsuleIDs)
            
            // Filtra as cápsulas por status
            self.inProgressCapsules = allCapsules.filter { $0.status == .inProgress }
            
            // Consideramos completed ou opened como "Concluídas" na Home
            self.completedCapsules = allCapsules.filter { $0.status == .completed || $0.status == .opened }
            
            // Verifica se foram feitos updates
            await checkIfCapsuleIsValidOffensive(user: currentUser)
            
            // faz fetch novamente
            allCapsules = try await capsuleService.fetchCapsules(IDs: capsuleIDs)
            
            // Filtra as cápsulas atualizadas por status
            self.inProgressCapsules = allCapsules.filter { $0.status == .inProgress }
            
            // Consideramos completed ou opened como "Concluídas" na Home
            self.completedCapsules = allCapsules.filter { $0.status == .completed || $0.status == .opened }
            
        } catch {
            print("Erro ao carregar dados da Home: \(error.localizedDescription)")
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
            
            await fetchCapsules()
            
        } catch {
            joinErrorMessage = "Unknown"
            print("❌ Erro ao entrar na cápsula: \(error)")
        }
    }
    
    func leaveCapsule(capsule: Capsule) async {
        do {
            var user = try await userService.getCurrentUser()

            print("ANTES de Apagar:")
            print(user)
            print(capsule)
            
            user.capsules.removeAll(where: { $0 == capsule.id })

            var updatedCapsule = capsule
            updatedCapsule.members.removeAll(where: { $0 == user.id })

            try await capsuleService.updateCapsule(capsule: updatedCapsule)

            _ = try await userService.updateUser(
                user,
                name: user.name,
                email: user.email,
                capsules: user.capsules
            )

            print("DEPOIS de Apagar:")
            let refreshedUser = try await userService.getCurrentUser()
            let refreshedCapsule = try await capsuleService.fetchCapsules(IDs: [capsule.id])

            print(refreshedUser)
            print(refreshedCapsule)

        } catch {
            print("Erro ao apagar cápsula: \(error.localizedDescription)")
        }
    }
}

