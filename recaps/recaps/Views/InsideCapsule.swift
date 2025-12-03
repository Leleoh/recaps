//
//  InsideCapsule.swift
//  recaps
//

//  Created by Leonel Ferraz Hernandez on 24/11/25.



import SwiftUI
import PhotosUI

struct InsideCapsule: View {
    
    var capsule: Capsule
    @State private var showInputComponent = false
    
    @State private var goToInputView = false
    
    @State private var showCamera = false
    @State private var showGallery = false
    
    @State private var vm = InsideCapsuleViewModel()
    
    // States required by CameraView
    @State private var capturedImage: UIImage?
    @State private var capturedPickerItem: PhotosPickerItem?
    
    var body: some View {
        
        ZStack {
            
            VStack{
                Text(capsule.name)
                    .padding(.top, 24)
                
                Spacer()
                
                ZStack{
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                        .frame(width: 350, height: 600)
                    
                    Text("Informações da capsula")
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Button{
                    withAnimation {
                        showInputComponent = true
                    }
                }label:{
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.blue)
                }
                .padding(.bottom, 40)

            }
            
            
            // ------------------
            // POP UP
            // ------------------
            if showInputComponent {
                
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showInputComponent = false
                        }
                    }
                
                SubmissionComponent(
                    onButtonPhotograph: {
                        showCamera = true
                    },
                    onButtonGallery: {
                        showGallery = true
                    }
                )
                .applyLiquidGlass(shape: RoundedRectangle(cornerRadius: 32))
                .padding(.horizontal, 24)
            }
        }
        
    
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $capturedImage, selectedItem: $capturedPickerItem)
        }
        .onChange(of: capturedImage) { _, newImage in
            if let img = newImage {
                vm.selectedImages = [img]
                goToInputView = true
            }
            // Close overlays after capture
            if newImage != nil {
                showCamera = false
                showInputComponent = false
            }
        }
        
        .photosPicker(
            isPresented: $showGallery,
            selection: $vm.selectedPickerItems,
            maxSelectionCount: 5,
            matching: .images
        )
        
        .onChange(of: vm.selectedImages) { _, newImages in
                        if !newImages.isEmpty {
                            goToInputView = true
                            showInputComponent = false
                        }
                    }
        .navigationDestination(isPresented: $goToInputView) {
            InputSubmissionView(viewModel: InputSubmissionViewModel(images: vm.selectedImages, capsuleID: capsule.id))
                    }
        .onDisappear {
                vm.selectedImages.removeAll()
                vm.selectedPickerItems.removeAll()
                
                capturedImage = nil
                capturedPickerItem = nil
            }
//        .confirmationDialog(
//            "Add a Memory",
//            isPresented: $showInputComponent,
//            titleVisibility: .visible
//        ) {
//            
//            Button("Photograph the moment") {
//                showCamera = true
//            }
//            
//            Button("Choose from gallery") {
//                showGallery = true
//            }
//
//            Button("Cancel", role: .cancel) {}
//        }
    }
}

#Preview {

    InsideCapsule(capsule: Capsule(
        id: UUID(),
        code: "PREVIEW",
        submissions: [],
        name: "Cápsula de Teste",
        createdAt: Date(),
        offensive: 0,
        offensiveTarget: 50,
        lastSubmissionDate: Date(),
        validOffensive: true,
        lives: 3,
        members: [],
        ownerId: "",
        status: .inProgress
    ))
}
