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
    private let ck = UserService()
    
    private let defaults = UserDefaults.standard
    init() { self.userId = getUserId() }
    var userId: String = ""
    var isLoading = false
    
    var isSignedIn: Bool {
        !userId.isEmpty
    }
    
    func handleAuthResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            
            let newUserId = credential.user
            let newEmail = credential.email ?? ""
            let newName = credential.fullName?.givenName ?? ""
            
            self.userId = newUserId
            
            do {
                let _ = try await ck.getCurrentUser(userId: newUserId)
                
                saveUserId(userId)
                
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
                
                _ = try? await ck.createUser(user: newUser)
                
                saveUserId(userId)
                
                print("Novo usuário criado no CloudKit")
            }
            
        case .failure(let error):
            print("Erro no Sign In With Apple:", error)
        }
    }
    
    //Salvar localmente  usuário logado
    func loadUserId() -> String {
        return UserDefaults.standard.string(forKey: "userId") ?? ""
    }
    func saveUserId(_ id: String) {
        defaults.set(id, forKey: "userId")
    }
    func getUserId() -> String {
        defaults.string(forKey: "userId") ?? ""
    }
    func logout() {
        defaults.removeObject(forKey: "userId")
    }
    
    func getCurrentUser() async -> User? {
        try? await ck.getCurrentUser(userId: userId)
    }
}
