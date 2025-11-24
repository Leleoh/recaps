//
//  CreateCapsuleView.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 21/11/25.
//

import SwiftUI

import SwiftUI

struct CreateCapsuleView: View {
    @Environment(\.dismiss) var dismiss
    @State private var capsulename: String = "Terceirão"
    @State private var selectionValue: Int = 0
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // Botão Placeholder de Fotos
                Button {
                    // Chamar método da ViewModel que abre o picker de fotos.
                } label: {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.title)
                        Text("Escolha 3 fotos de sua galeria")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.top, 40)
                
                // Input de Nome
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nome:")
                        .foregroundStyle(.black)
                    
                    TextField("capsule name", text: $capsulename)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                        )
                }
                
                
                // Input de Ofensiva
                HStack(alignment: .center, spacing: 16) {
                    Text("Tempo de ofensiva:")
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Picker(selection: $selectionValue) {
                        ForEach(1...365, id: \.self) { days in
                            Text("\(days)").tag(days)
                        }
                    } label: {
                        Text("Teste")
                    }
                    .pickerStyle(.menu)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                    )

                    
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Botão Cancelar (Esquerda)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                
                // Título Central
                ToolbarItem(placement: .principal) {
                    Text("Title")
                        .font(.headline)
                }
                
                // Botão Salvar (Direita)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //                        viewModel.createRecap { success in
                        //                            if success { dismiss() }
                        //                        }
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.white)
                            .padding(8)
                        //                            .background(viewModel.title.isEmpty ? Color.gray : Color.black) // Desabilitado visualmente
                            .clipShape(Circle())
                    }
                    //                    .disabled(viewModel.title.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}

#Preview {
    CreateCapsuleView()
}
