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
        // Ensure the credential is an AppleID credential
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            
            // User information provided by Sign in with Apple
            let newUserId = credential.user
            let newEmail = credential.email ?? ""
            let givenName = credential.fullName?.givenName ?? ""
            let familyName = credential.fullName?.familyName ?? ""
            let newName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)

            // Save the user ID locally to keep the user signed in
            userService.saveUserId(newUserId)
            self.hasUser = true
            
            do {
                // Try to fetch an existing user in CloudKit
                _ = try await userService.getCurrentUser()
    
                print("Usuário encontrado no CloudKit")
                
            } catch {
                // If the user cannot be found create a new one
                print("Usuário não existe. Criando no CloudKit...")
                
                let newUser = User(
                    id: newUserId,
                    name: newName,
                    email: newEmail,
                    capsules: []
                )
                
                print(newUser.name)
                print(newUser.email)
                
                _ = try? await userService.createUser(user: newUser)
                
                
                print("Novo usuário criado no CloudKit")
            }
            
        case .failure(let error):
            print("Erro no Sign In With Apple:", error)
        }
    }
}
