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
        Group{
            if viewModel.isSignedIn {
                ContentView()
            }
            else {
                NavigationView {
                    VStack {
                        SignInWithAppleButton(.continue) { request in
                            request.requestedScopes = [.email, .fullName]
                        } onCompletion: { result in
                            viewModel.handleAuthResult(result)
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
            .onAppear {
                viewModel.checkExistingAccount()
            }
    }
}

#Preview {
    AuthenthicationView()
}
