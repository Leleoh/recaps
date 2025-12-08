//
//  MockUserService.swift
//  recapsTests
//
//  Created by Ana Carolina Poletto on 24/11/25.
//

import Foundation
@testable import recaps

class MockUserService: UserServiceProtocol {
    
    // MARK: - Mocked State / Configurable Returns
    var userId: String = "mock-user-id"
    
    // O usuário que será retornado ao chamar getCurrentUser
    var mockCurrentUser: User?
    
    // O usuário que será retornado ao chamar getUser(id)
    var mockFetchedUser: User?
    
    // Controle de erros forçados
    var shouldThrowOnGetCurrent = false
    var shouldThrowOnUpdate = false

    // MARK: - Flags (Spy Pattern para Testes)
    var didCreate = false
    var didGetCurrentUser = false
    var didGetUser = false
    var didUpdateUser = false
    var didDeleteUser = false
    var didLoadUserId = false
    var didSaveUserId = false
    var didLogout = false
    var didChangeCompletedCapsuleToOpenCapsule = false

    // MARK: - Captured Values (Para verificar o que foi passado)
    var createdUser: User?
    var deletedUserId: String?
    var fetchedUserId: String?
    
    // MARK: - Protocol Methods
    
    func getCurrentUser() async throws -> User {
        didGetCurrentUser = true

        if shouldThrowOnGetCurrent {
            throw NSError(domain: "MockUserService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Forced error on getCurrentUser"])
        }

        if let user = mockCurrentUser {
            return user
        }

        // Retorno padrão caso não tenha sido configurado
        return User(id: userId, name: "Mock User", email: "mock@test.com", capsules: [], openCapsules: [])
    }

    func getUser(with id: String) async throws -> User {
        didGetUser = true
        fetchedUserId = id

        if let user = mockFetchedUser {
            return user
        }
        
        // Se o ID solicitado for o do usuário atual mockado, retorna ele
        if let current = mockCurrentUser, current.id == id {
            return current
        }

        throw NSError(domain: "MockUserService", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not found"])
    }

    func createUser(user: User) async throws {
        didCreate = true
        createdUser = user
        // Simula o salvamento
        mockCurrentUser = user
        userId = user.id
    }

    func updateUser(_ user: User, name: String?, email: String?, capsules: [UUID]?, openCapsules: [UUID]?) async throws -> User {
        didUpdateUser = true

        if shouldThrowOnUpdate {
            throw NSError(domain: "MockUserService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Forced error on updateUser"])
        }

        // Cria o objeto atualizado
        let updatedUser = User(
            id: user.id,
            name: name ?? user.name,
            email: email ?? user.email,
            capsules: capsules ?? user.capsules,
            openCapsules: openCapsules ?? user.openCapsules
        )
        
        // Atualiza o estado do mock para refletir a mudança
        self.mockCurrentUser = updatedUser
        
        return updatedUser
    }
    
    func changeCompletedCapsuleToOpenCapsule(user: User, capsuleId: UUID) async throws {
        didChangeCompletedCapsuleToOpenCapsule = true
        
        // Simula a lógica real: remove de capsules e adiciona em openCapsules
        // Isso é importante para testar se a View atualiza corretamente
        if var currentUser = mockCurrentUser {
            
            // Remove dos arrays (se existir) para evitar duplicatas ou inconsistência
            if let index = currentUser.capsules.firstIndex(of: capsuleId) {
                currentUser.capsules.remove(at: index)
            }
            
            if !currentUser.openCapsules.contains(capsuleId) {
                currentUser.openCapsules.append(capsuleId)
            }
            
            // Salva o estado atualizado no mock
            self.mockCurrentUser = currentUser
        }
    }

    func deleteUser() async throws {
        didDeleteUser = true
        deletedUserId = userId
        mockCurrentUser = nil
        logout()
    }

    // MARK: - User ID Handling

    func loadUserId() -> String? {
        didLoadUserId = true
        return userId.isEmpty ? nil : userId
    }

    func saveUserId(_ id: String) {
        didSaveUserId = true
        userId = id
    }

    func getUserId() -> String {
        // didLoadUserId = true // Opcional, dependendo de como você quer rastrear
        return userId
    }

    func logout() {
        didLogout = true
        userId = ""
        mockCurrentUser = nil
    }
    
    // MARK: - Helper para limpar estado entre testes
    func resetTrackers() {
        didCreate = false
        didGetCurrentUser = false
        didGetUser = false
        didUpdateUser = false
        didDeleteUser = false
        didLoadUserId = false
        didSaveUserId = false
        didLogout = false
        didChangeCompletedCapsuleToOpenCapsule = false
        
        shouldThrowOnGetCurrent = false
        shouldThrowOnUpdate = false
    }
}
