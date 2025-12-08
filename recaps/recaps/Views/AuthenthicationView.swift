//
//  ContentView.swift
//  SignInWithApple
//
//  Created by Ana Carolina Poletto on 18/11/25.
//

import AuthenticationServices
import SwiftUI

struct AuthenthicationView: View {
    @State var viewModel = AuthenthicationViewModel()
    
    var body: some View {
        VStack(spacing: 62) {
            Image(.loginLock)
            
            VStack(spacing: 12){
                Text("Recapsule")
                    .font(.custom("CoveredByYourGrace", size: 48))
                
                Text("Unlock memories")
                    .font(.title3)
            }
            
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                Task { @MainActor in
                    await viewModel.handleAuthResult(result)
                }
            }
            .signInWithAppleButtonStyle(.white)
            .cornerRadius(32)
            .frame(height: 54)
            .padding()
        }
    }
}




#Preview {
    AuthenthicationView()
}
