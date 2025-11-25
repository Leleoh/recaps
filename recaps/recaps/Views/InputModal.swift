//
//  InputModal.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 21/11/25.
//

import SwiftUI
import PhotosUI

struct InputModal: View {
    
    var capsuleID: UUID
    private let ckService = CapsuleService()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showCamera = false
    @State private var showGallery = false
//    @State private var isUploading = false
//    @State private var errorMessage: String? = nil
    
    @State private var VM = InputViewModel()
    
//    @State private var caption: String = ""
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        ZStack{
            //Fundo para dar dismiss no teclado
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            
            VStack(spacing: 20) {
                
                if let img = VM.selectedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200)
                }else {
                    // Placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 200, height: 150)
                        .overlay(Image(systemName: "photo").font(.largeTitle).foregroundStyle(.gray))
                }
                HStack {
                    Button { showCamera = true } label: {
                        Label("Câmera", systemImage: "camera")
                    }
                    .buttonStyle(.bordered)
                    
                    Button { showGallery = true } label: {
                        Label("Galeria", systemImage: "photo")
                    }
                    .buttonStyle(.bordered)
                }
                
                TextField("Digite uma legenda", text: $VM.caption)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                if let error = VM.errorMessage {
                    Text(error).foregroundStyle(.red).font(.caption)
                }
                
                Button{
                    Task{
                        await VM.saveMemory(capsuleID: capsuleID)
                    }
                } label:{
                    if VM.isUploading{
                        ProgressView().tint(.white)
                    }else{
                        Text("Adicionar memória").bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(VM.selectedImage == nil ? Color.gray : Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(VM.selectedImage == nil || VM.isUploading)
                
            }
        }
        .padding()
        .onChange(of: VM.shouldDismiss){_, shouldDimiss in
            if shouldDimiss {
                dismiss()
            }
            
        }
        .sheet(isPresented: $showCamera) {
            CameraView(image: $VM.selectedImage, selectedItem: $selectedItem)
        }
        .photosPicker(isPresented: $showGallery, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { old, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run{
                        VM.selectedImage = img
                    }
                }
            }
        }
        
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


#Preview {
    InputModal(capsuleID: UUID())
}
