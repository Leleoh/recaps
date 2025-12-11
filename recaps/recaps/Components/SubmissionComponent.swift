//
//  SubmissionComponent.swift
//  recaps
//
//  Created by Fernando Sulzbach on 02/12/25.
//
import Foundation
import PhotosUI
import SwiftUI

struct SubmissionComponent: View {
    
    var onButtonPhotograph: () -> Void
    var onButtonGallery: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            
            Button(action: onButtonPhotograph) {
                Text("Photograph the moment")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                    )
            }
            
            Button(action: onButtonGallery) {
                Text("Choose from gallery")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                    )
            }
        }
        .padding(14)
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 34)
                .fill(.quaternary)
                .opacity(0.8)
            
        )
    }
}

#Preview {
    SubmissionComponent(onButtonPhotograph: { print("ola") }, onButtonGallery: { print("hello") } )
}
