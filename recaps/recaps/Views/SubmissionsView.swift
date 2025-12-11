//
//  CreateCapsuleView.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 21/11/25.
//

import SwiftUI

struct SubmissionsView: View {
    
    var submissions: [Submission] = []
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(submissions) { submission in
                    
                    VStack (alignment: .leading) {
                        Text(submission.id.uuidString)
                            .font(.system(size: 8, weight: .regular))
                    
                        if let url = submission.imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 200)
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cornerRadius(8)
                    
                }
            }
            .padding()
        }
        
    }
}

#Preview {
    CreateCapsuleView()
}
