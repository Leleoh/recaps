//
//  ProfileView.swift
//  recaps
//
//  Created by Ana Poletto on 02/12/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Profile")
                .font(.largeTitle)
                .padding()

            Text("Name")
            Text(viewModel.userName)

            Text("Email")
            Text(viewModel.userEmail)

            HStack {
                Button("Logout") {
                    viewModel.logout()
                    dismiss()
                }

                Button("Delete Account") {
                    Task {
                        await viewModel.deleteAccount()
                        await MainActor.run {
                            dismiss()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadUser()
        }
    }
}

