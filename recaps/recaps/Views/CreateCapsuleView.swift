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
    @State private var viewModel = CreateCapsuleViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // MARK: - Área de Seleção de Fotos
                PhotosPicker(
                    selection: $viewModel.selectedPickerItems,
                    maxSelectionCount: 3,
                    matching: .images
                ) {
                    
                    if viewModel.selectedImages.isEmpty {
                        
                        InitialPhotosComponent()
                           
                        
                    } else {
                        // Estado com Fotos Selecionadas
                        FilledPhotos(images: viewModel.selectedImages)
                            
                    }
                }
                .frame(height: 362)
                .padding(.top, 90)
                
                // Input de Nome
                VStack(alignment: .leading, spacing: 8) {
                    
                    NameComponent(text: $viewModel.capsuleName)
                    //                        .padding(.top, 83)
                    
                }
                
                // Input de Ofensiva
                VStack{
                    HStack(alignment: .center, spacing: 16) {
                        Text("Streak days")
                            .foregroundColor(Color(.label))
                        
                        Spacer()
                        
                        Picker("", selection: $viewModel.offensiveTarget) {
                            ForEach([1,7,30,60,90,180,360], id: \.self) { days in
                                Text("\(days)").tag(days)
                                    .tag(days)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.sweetnSour)
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(Color("SheetBackground"))
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                        )
                    }
                    .padding(.top, 24)
                    
                    Text("Streak days is the number of consecutive days saving memories that will be required for the Recapsule to open.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                        .foregroundStyle(.secondary)
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
                            let success = await viewModel.createCapsule()
                            if success {
                                dismiss()
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
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    CreateCapsuleView()
}
