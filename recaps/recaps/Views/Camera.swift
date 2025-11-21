//
//  Camera.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 19/11/25.
//

import SwiftUI
import PhotosUI

struct Camera: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingCamera = false
    
    @State private var submissions: [Submission] = []
    
    private let CKService = CloudKitService()
    
    let mockSubmission = Submission(
        id: UUID(),
        imageURL: nil,
        description: "A vida é curta, vive cada momento!",
        authorId: UUID(),
        date: Date(),
        capsuleID: UUID()
    )
    
    var body: some View {
        VStack(spacing: 8) {
            VStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500, height: 600)
                } else {
                    Text("No image selected")
                        .foregroundStyle(Color.gray)
                }
                
                Button(action: {
                    showingCamera = true
                }) {
                    Text("Tirar foto")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .sheet(isPresented: $showingCamera) {
                    CameraView(image: $selectedImage, selectedItem: $selectedItem)
                }
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Select Photo")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                
                Button {
                    guard let selectedImage else { return }
                    Task {
                        try await CKService.createSubmission(
                            submission: mockSubmission,
                            capsuleID: mockSubmission.capsuleID,
                            image: selectedImage
                        )
                    }
                } label: {
                    Text("Create Submission")
                }
                
                Button {
                    Task {
                        if let idToFetch = UUID(uuidString: "1E79F8C0-5095-4ACE-AFBE-688012924836") {
                            submissions = try await CKService.fetchSubmissions(capsuleID: idToFetch)
                        }
                    }
                } label: {
                    Text("Fetch Submissions")
                }
                
                Button {
                    Task {
                        let idsToFetch = [
                            UUID(uuidString: "116AF188-382F-4F93-8F4C-572E0015ADA1"),
                            UUID(uuidString: "14313D1D-0727-4950-B59A-74D3C543AB1D"),
                        ]
                        
                        try await print(CKService.fetchCapsules(IDs: idsToFetch as! [UUID]))
                        
                    }
                } label: {
                    Text("Fetch Capsules")
                }
            }
            
            VStack {
                ForEach(submissions) { submission in
                    VStack {
                        Text(submission.id.uuidString)
                        if let url = submission.imageURL,
                           let data = try? Data(contentsOf: url),
                           let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 50, height: 50)
                        } else {
                            Text("No image")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .onChange(of: selectedItem) { oldItem, newItem in
            if let newItem = newItem {
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
        }
    }
}

#Preview {
    Camera()
}
