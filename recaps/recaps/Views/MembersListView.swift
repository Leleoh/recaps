//
//  ProfileView 2.swift
//  recaps
//
//  Created by Fernando Sulzbach on 04/12/25.
//

import SwiftUI

struct MembersListView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var members: [User]
    
    var body: some View {
            ScrollView {
                VStack (alignment: .leading) {
                    ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                        HStack (alignment: .firstTextBaseline, spacing: 8) {
                            Text(String(format: "%02d", index + 1))
                                .font(.title3)
                                .frame(width: 30, height: 28)
                            
                            Text(member.name)
                                .font(.coveredByYourGraceSignature)
                        }
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.top, 24)
                
            }
        
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .navigationBarTitleDisplayMode( .inline )
        
        .toolbar {
            ToolbarItem(placement: .principal) {
                    Text("Members")
                    .font(.system(size: 17, weight: .semibold))
                }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
}
