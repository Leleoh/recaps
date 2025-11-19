//
//  Camera.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 19/11/25.
//

import SwiftUI
import PhotosUI

struct Camera: View {
    @State private var selectedItem: PhotosPickerItem? //
    @State private var selectedImage: UIImage?
    @State private var showingCamera = false
    
    var body: some View {
        VStack{
            if let selectedImage = selectedImage{
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 500, height: 600)
            }else{
                Text("No image selected")
                    .foregroundStyle(Color.gray)
            }
            
            Button(action:{
                showingCamera = true
            }){
                Text("Tirar foto")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .sheet(isPresented: $showingCamera){
                CameraView(image: $selectedImage)
            }
            
            
            PhotosPicker(selection: $selectedItem,
                         matching: .images,
                         photoLibrary: .shared()
            ){
                Text("Select Photo")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                
            }
            .onChange(of: selectedItem) { oldItem, newItem in
                if let newItem = newItem{
                    Task{
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                            let image = UIImage(data: data){
                                selectedImage = image
                            }
                        }
                    }
                }
            }
        }
    
}

#Preview {
    Camera()
}
