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
        NavigationStack {
            ScrollView{
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.userName)
                            .font(.coveredByYourGraceTitle)
                        Text(viewModel.userEmail)
                            .font(.footnote)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(.sheetBackground)
                    )
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settings")
                            .font(.headline)
                        
                        HStack {
                            Toggle(isOn: $viewModel.allowNotifications) {
                                Text("Allow notifications")
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(.sheetBackground)
                        )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Button {
                                Task {
                                    await viewModel.deleteAccount()
                                }
                                dismiss()
                        } label: {
                            Text("Delete account")
                                .foregroundStyle(.red)
                        }
                        
                        Divider()
                            .padding(.horizontal, 8)
                        
                        Button {
                            viewModel.logout()
                            dismiss()
                        } label: {
                            Text("Sign out")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(.sheetBackground)
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 32)
        }
        .navigationTitle("Account")
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                
            }
        }
    }
        .task {
            await viewModel.loadUser()
        }
}
}


#Preview {
    ProfileView()
}
