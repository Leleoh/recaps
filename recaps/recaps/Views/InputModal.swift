//
//  InputModal.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 21/11/25.
//

import SwiftUI
import PhotosUI

struct InputModal: View {
    
    @State private var showOptions: Bool = false
    @State private var showCamera: Bool = false
    @State private var showGallery: Bool = false
    
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack{
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
            }
            Button {
                showOptions.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.blue)
            }
            .sheet(isPresented: $showOptions){
                PhotoOptionsModal(
                    onTakePhoto:{
                        showOptions = false
                        showCamera = true
                    },
                    onChoosePhoto: {
                        showOptions = false
                        showGallery = true
                    }
                )
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        //Abre a view da câmera
        .sheet(isPresented: $showCamera){
            CameraView(image: $selectedImage, selectedItem: $selectedItem)
        }
        
        //Abre o PhotoPicker
        .photosPicker(isPresented: $showGallery, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { old, item in
            Task{
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data){
                    selectedImage = img
                }
                
            }
        }
    }
}


#Preview {
    InputModal()
}
