//
//  CreateCapsuleView.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 21/11/25.
//

import SwiftUI
import PhotosUI

struct CreateCapsuleView: View {
    @Environment(\.dismiss) var dismiss
    var onFinish: (String) -> Void = { _ in }
    
    @State private var viewModel = CreateCapsuleViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // MARK: - Área de Seleção de Fotos
                PhotosPicker(
                    selection: $viewModel.selectedPickerItems,
                    maxSelectionCount: nil,
                    matching: .images
                ) {
                    VStack(spacing: 12) {
                        if viewModel.selectedImages.isEmpty {
                            // EmtyState
                            Image(systemName: "camera.fill")
                                .font(.title)
                            Text("Escolha pelo menos 3 fotos")
                                .font(.headline)
                        } else {
                            // Estado com Fotos Selecionadas (Carrossel)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.selectedImages, id: \.self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 140)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .clipped()
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 160)
                            
                            Text("\(viewModel.selectedImages.count) fotos selecionadas")
                                .font(.caption)
                                .foregroundStyle(viewModel.selectedImages.count >= 3 ? .green : .red)
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Input de Nome
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nome:")
                        .foregroundStyle(.black)
                    
                    TextField("Nome da cápsula", text: $viewModel.capsuleName)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(Color.white)
                                .shadow(radius: 2, y: 2)
                        )
                }
                
                // Input de Ofensiva
                HStack(alignment: .center, spacing: 16) {
                    Text("Tempo de ofensiva:")
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Picker("", selection: $viewModel.offensiveTarget) {
                        ForEach(1...365, id: \.self) { days in
                            Text("\(days)").tag(days)
                        }
                    }
                    .pickerStyle(.menu)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                    )
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Botão Cancelar (Esquerda)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding(8)
                    }
                }
                
                // Título Central
                ToolbarItem(placement: .principal) {
                    Text("Nova Capsula")
                        .font(.headline)
                }
                
                // Botão Salvar (Direita)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            viewModel.code = viewModel.generateCode()
                            let success = await viewModel.createCapsule(code: viewModel.code)
                            if success {
                                dismiss()
                                onFinish(viewModel.code)
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.up")
                                .foregroundColor(viewModel.isValidToSave ? Color.black : Color.gray)
                        }
                    }
                    // Desabilita o botão se a validação falhar ou estiver carregando
                    .disabled(!viewModel.isValidToSave || viewModel.isLoading)
                }
            }
        }
    }
}

#Preview {
    CreateCapsuleView()
}
