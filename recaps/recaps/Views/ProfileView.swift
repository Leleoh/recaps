//
//  ProfileView.swift
//  recaps
//
//  Created by Ana Poletto on 02/12/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @Binding var user: User
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.name)
                            .font(.coveredByYourGraceTitle)
                        
                        Text(user.email)
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
                                viewModel.showDeleteAlert = true
                            } label: {
                                Text("Delete account")
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Divider()
                                .padding(.horizontal, 8)
                            
                            Button {
                                viewModel.showSignOutAlert = true
                            } label: {
                                Text("Sign out")
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
            .alert("Delete account?", isPresented: $viewModel.showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteAccount()
                    }
                    dismiss()
                }

                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your account and all associated data will be permanently deleted.")
            }
            
            .alert("Sign Out?", isPresented: $viewModel.showSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    viewModel.logout()
                    dismiss()
                }

                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You'll need to sign in again to access your account.")

            }
        }
    }
}
