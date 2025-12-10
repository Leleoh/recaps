//
//  HomeRecaps.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 19/11/25.
//

import SwiftUI

struct HomeRecapsView: View {
    
    @State private var viewModel = HomeRecapsViewModel()
    
    @State private var capsuleToNavigate: Capsule?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fundo da tela
                Image(.backgroundPNG)
                    .resizable()
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // MARK: Cabeçalho DA PÁGINA
                        VStack(alignment: .leading, spacing: 16) {
                            Text("My\nRecapsules")
                                .font(.appLargeTitle)
                                .lineLimit(2)
                                .foregroundStyle(.labelPrimary)
                            
                            // MARK: Botões Novo Recap / Juntar-se
                            HStack(spacing: 8) {
                                Button {
                                    viewModel.didTapNewRecap()
                                } label: {
                                    Text("Create New")
                                        .font(.headline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 24)
                                                .foregroundStyle(.sweetNSour)
                                        )
                                        .foregroundStyle(.labelPrimary)
                                }
                                
                                Button {
                                    viewModel.showJoinPopup = true
                                } label: {
                                    Text("Join Recapsule")
                                        .font(.headline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 24)
                                                .foregroundStyle(.labelPrimary)
                                        )
                                        .foregroundStyle(.sweetNSour)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(1.4)
                                Spacer()
                            }
                            .padding(.top, 200)
                        } else {
                            // MARK: Cápsulas em andamento
                            VStack() {
                                if viewModel.inProgressCapsules.isEmpty {
                                    VStack {
                                        Text("No capsules currently in progress.\nCreate the first one!")
                                            .font(.appBody)
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.labelTertiary)
                                            .padding(.horizontal, 40)
                                    }
                                    .frame(height: 420)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 24)
                                    .cornerRadius(24)
                                } else {
                                    TabView {
                                        ForEach(viewModel.inProgressCapsules) { recap in
                                            Button {
                                                if recap.status == .completed {
                                                    Task {
                                                        try await viewModel.changeCompletedCapsuleToOpenCapsule(capsuleID: recap.id)
                                                        capsuleToNavigate = recap
                                                        await viewModel.fetchCapsules()
                                                    }
                                                } else {
                                                    capsuleToNavigate = recap
                                                }
                                                
                                            } label: {
                                                VStack (spacing: 24){
                                                    CloseCapsule(capsule: recap)
                                                    NameComponent(text: .constant(recap.name))
                                                        .disabled(true)
                                                }
                                            }
                                            .buttonStyle(.plain)
                                            .contextMenu {
                                                Button {
                                                    UIPasteboard.general.string = recap.code
                                                } label: {
                                                    Label("Copy invite code", systemImage: "doc.on.doc")
                                                }
                                                
                                                Button(role: .destructive) {
                                                    Task {
                                                        await viewModel.leaveCapsule(capsule: recap)
                                                        Task { await viewModel.fetchCapsules() }
                                                    }
                                                } label: {
                                                    Label("Leave Recapsule", systemImage: "rectangle.portrait.and.arrow.right")
                                                }
                                            }
                                        }
                                    }
                                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                                    .frame(height: 420)
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        
                        // MARK: Cápsulas concluídas
                        VStack(alignment: .leading, spacing: 16) {
                            if viewModel.completedCapsules.isEmpty {
                                // Nada deve aparecer aqui.
                            } else {
                                Text("Opened")
                                    .font(.appTitle2)
                                    .foregroundStyle(.labelSecondary)
                                    .padding(.horizontal, 24)
                                
                                let columns = [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ]
                                
                                LazyVGrid(columns: columns, spacing: 24) {
                                    ForEach(viewModel.completedCapsules) { recap in
                                        NavigationLink {
                                            PostOpenedCapsuleView(capsule: recap, viewModel: PostOpenedCapsuleViewModel(capsule: recap), showLottie: false)
//                                            Text("Openend Capsule View Placeholder.")
                                        } label: {
                                            VStack(spacing: 8){
                                                OpenCapsule(capsule: recap)
                                                
                                                NameComponent(text: .constant(recap.name))
                                                    .disabled(true)
                                                    .padding(.horizontal, 16)
                                            }
                                        }
                                        .contextMenu {
                                            // Apenas Sair
                                            Button(role: .destructive) {
                                                Task {
                                                    await viewModel.leaveCapsule(capsule: recap)
                                                }
                                            } label: {
                                                OpenCapsule(capsule: recap)
                                            }
                                            .contextMenu {
                                                // Apenas Sair
                                                Button(role: .destructive) {
                                                    Task {
                                                        await viewModel.leaveCapsule(capsule: recap)
                                                    }
                                                } label: {
                                                    Label("Leave Recapsule", systemImage: "rectangle.portrait.and.arrow.right")
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 16)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
                
            }
            // Configuração da Navigation Bar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showProfile = true
                    } label: {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.labelSecondary)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            // MARK: - Gerenciamento de Popups via Overlay
            .overlay {
                if viewModel.showJoinPopup {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        JoinPopUp(
                            isShowing: $viewModel.showJoinPopup,
                            join: { code in
                                Task {
                                    if let capsule = await viewModel.joinCapsule(code: code) {
                                        capsuleToNavigate = capsule
                                        viewModel.showJoinPopup = false
                                        await viewModel.fetchCapsules()
                                    }
                                    
                                    if viewModel.joinErrorMessage == nil {
                                        withAnimation { viewModel.showJoinPopup = false }
                                    }
                                }
                            },
                            joinErrorMessage: $viewModel.joinErrorMessage
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    .zIndex(2)
                } else if viewModel.showPopup {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    viewModel.showPopup = false
                                }
                            }
                        
                        InvitePopUp(
                            isShowing: $viewModel.showPopup,
                            code: viewModel.inviteCode
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    .zIndex(2)
                }
            }
            // Navigation to InsideCapsule when capsuleToNavigate is set
            .navigationDestination(item: $capsuleToNavigate) { capsule in
                if capsule.status == .completed {
                    PostOpenedCapsuleView(capsule: capsule, viewModel: PostOpenedCapsuleViewModel(capsule: capsule))
                } else {
                    InsideCapsule(capsule: capsule)
                }
                
                
            }
            
        }
        
        .refreshable {
            await viewModel.refreshCapsules()
        }
        
        .task {
            await viewModel.fetchCapsules()
            await viewModel.fetchUser()
//            _ = try? await viewModel.userService.changeCompletedCapsuleToOpenCapsule(user: viewModel.user, capsuleId: UUID(uuidString: "710D4E62-6968-4073-B012-53290D3535AE")!)
        }
        .sheet(isPresented: $viewModel.showCreateCapsule, onDismiss: {
            Task { await viewModel.fetchCapsules() }
        }) {
            CreateCapsuleView { code in
                viewModel.inviteCode = code
                viewModel.showPopup = true
            }
        }
        
        .sheet(isPresented: $viewModel.showProfile, onDismiss: {
        }) {
            ProfileView(user: $viewModel.user)
        }
    }
}

#Preview {
    HomeRecapsView()
}
