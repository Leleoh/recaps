//
//  AuthViewModel.swift
//  SignInWithApple
//
//  Created by Ana Carolina Poletto on 18/11/25.
//

import SwiftUI
import AuthenticationServices
import CloudKit

@Observable
class AuthenthicationViewModel {
    // MARK: Properties
    private let userService = UserService()
    var hasUser = false
    
    // MARK: Computed Properties
    var isSignedIn: Bool {
        !userService.userId.isEmpty
    }
    
    // MARK: Auth Handling (Sign in With Apple)
    @MainActor
    func handleAuthResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            
            let newUserId = credential.user
            let newEmail = credential.email ?? ""
            let givenName = credential.fullName?.givenName ?? ""
            let familyName = credential.fullName?.familyName ?? ""
            let newName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)

            do {
                // 1. Tenta buscar usuário no CloudKit
                let existingUser = try await userService.getUser(with: newUserId)

                print("Usuário encontrado no CloudKit:", existingUser.name)

                // 2. Só agora salva localmente
                userService.saveUserId(newUserId)
                self.hasUser = true

            } catch {
                print("Usuário não existe. Criando no CloudKit...")

                let newUser = User(
                    id: newUserId,
                    name: newName,
                    email: newEmail,
                    capsules: [],
                    openCapsules: []
                )

                _ = try? await userService.createUser(user: newUser)

                // Agora sim salva o userId localmente
                userService.saveUserId(newUserId)
                self.hasUser = true

                print("Novo usuário criado no CloudKit")
            }

        case .failure(let error):
            print("Erro no Sign In With Apple:", error)
        }
    }

}
