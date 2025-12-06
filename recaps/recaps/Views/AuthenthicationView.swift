//
//  ContentView.swift
//  SignInWithApple
//
//  Created by Ana Carolina Poletto on 18/11/25.
//

import AuthenticationServices
import SwiftUI

struct AuthenthicationView: View {
    var viewModel = AuthenthicationViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Group {
            if viewModel.isSignedIn || viewModel.hasUser {
                HomeRecapsView(
                    onLogout: {
                        viewModel.signOut()
                    }
                )
            } else {
                NavigationView {
                    VStack {
                        SignInWithAppleButton(.continue) { request in
                            request.requestedScopes = [.email, .fullName]
                        } onCompletion: { result in
                            Task { @MainActor in
                                await viewModel.handleAuthResult(result)
                            }
                        }
                        .signInWithAppleButtonStyle(
                            colorScheme == .dark ? .white : .black
                        )
                        .frame(height: 50)
                        .padding()
                    }
                    .navigationTitle("Sign In With Apple")
                }
            }
        }
    }
}

#Preview {
    AuthenthicationView()
}
