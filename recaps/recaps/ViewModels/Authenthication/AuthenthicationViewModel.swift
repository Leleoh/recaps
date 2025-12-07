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

    var isSignedIn: Bool = false

    init() {
        let _ = userService.loadUserId()
        self.isSignedIn = !userService.userId.isEmpty
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
                _ = try await userService.getUser(with: newUserId)
                userService.saveUserId(newUserId)
                self.isSignedIn = true

            } catch {
                let newUser = User(
                    id: newUserId,
                    name: newName,
                    email: newEmail,
                    capsules: [],
                    openCapsules: []
                )

                _ = try? await userService.createUser(user: newUser)
                userService.saveUserId(newUserId)
                self.isSignedIn = true
            }

        case .failure(let error):
            print("Erro:", error)
        }
    }
}
