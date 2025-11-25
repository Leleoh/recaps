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
    private let userService = UserService()
    var isLoading = false
    
    var isSignedIn: Bool {
        !userService.userId.isEmpty
    }
    
    func handleAuthResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            
            let newUserId = credential.user
            let newEmail = credential.email ?? ""
            let newName = credential.fullName?.givenName ?? ""
            
            userService.userId = newUserId
            
            do {
                userService.saveUserId(userService.userId)
                
                let _ = try await userService.getCurrentUser()
                
                print("Usuário encontrado no CloudKit")
                
                
            } catch {
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
                
                userService.saveUserId(userService.userId)
                
                print("Novo usuário criado no CloudKit")
            }
            
        case .failure(let error):
            print("Erro no Sign In With Apple:", error)
        }
    }
}
