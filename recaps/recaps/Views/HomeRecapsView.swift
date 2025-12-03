//
//  HomeRecaps.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 19/11/25.
//

import SwiftUI

struct HomeRecapsView: View {
    
    @State private var viewModel = HomeRecapsViewModel()
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack() {
                    
                    // MARK: Cabeçalho DA PÁGINA
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .center) {
                            
                            Text("Minhas recaps")
                                .font(.appLargeTitle)
                            
                            Spacer()
                            
                            // MARK: Botão de perfil
                            Button {
                                // TODO: Chamar view do perfil quando implementada
                            } label: {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10.5)
                                    .padding(.vertical, 13)
                            }
                            .frame(width: 48, height: 48)
                            .applyLiquidGlass(shape: Circle())
                            .buttonStyle(.plain)
                        }
                        
                        // MARK: Botões Novo Recap / Juntar-se
                        HStack(spacing: 12) {
                            Button {
                                viewModel.didTapNewRecap()
                            } label: {
                                Text("Novo recap")
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.accentColor.opacity(0.15))
                                    )
                            }
                            
                            Button {
                                viewModel.showJoinPopup = true
                            } label: {
                                Text("Juntar-se")
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.accentColor, lineWidth: 1.5)
                                    )
                            }
                        }
                    }
                    .padding([.top, .horizontal], 16)
                    
                    
                    // MARK: Cápsulas em andamento
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Em Andamento")
                        
                        if viewModel.inProgressCapsules.isEmpty {
                            Text("Nenhuma cápsula em andamento")
                                .foregroundStyle(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            TabView {
                                ForEach(viewModel.inProgressCapsules) { recap in
                                    NavigationLink {
                                        InsideCapsule(capsule: recap)
                                    } label: {
                                        CloseCapsule(capsule: recap)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        }
                    }
                    .frame(maxHeight: 296)
                    .padding()
                    
                    
                    // MARK: Cápsulas concluídas
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Concluídas")
                        
                        if viewModel.completedCapsules.isEmpty {
                            Text("Nenhuma cápsula concluída ainda")
                                .foregroundStyle(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            let columns = [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ]
                            
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(viewModel.completedCapsules) { recap in
                                        OpenCapsule(capsule: recap)
                                            .frame(maxWidth: .infinity, maxHeight: 131)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            
            // MARK: Popup de join
            if viewModel.showJoinPopup {
                JoinPopUp(
                    isShowing: $viewModel.showJoinPopup,
                    join: { code in
                        Task {
                            await viewModel.joinCapsule(code: code)
                        }
                    },
                    joinErrorMessage: $viewModel.joinErrorMessage
                )
            }
            
            // MARK: Popup de invite
            if viewModel.showPopup {
                InvitePopUp(
                    isShowing: $viewModel.showPopup,
                    code: viewModel.inviteCode
                )
            }
        }
        .task {
            await viewModel.fetchCapsules()
        }
        .sheet(isPresented: $viewModel.showCreateCapsule, onDismiss: {
            Task { await viewModel.fetchCapsules() }
        }) {
            CreateCapsuleView { code in
                viewModel.inviteCode = code
                viewModel.showPopup = true
            }
        }
    }
}

#Preview {
    HomeRecapsView()
}
