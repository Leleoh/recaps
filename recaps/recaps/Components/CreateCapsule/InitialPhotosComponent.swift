//
//  InitialPhotosComponent.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 25/11/25.
//

import SwiftUI

struct InitialPhotosComponent: View {
    var body: some View {
        
        VStack{
            ZStack{
                Rectangle()
                    .frame(width: 200, height: 150)
                    .foregroundColor(.thirdEmptyPhoto)
                    .shadow(radius: 10)
                    .padding()
                    .offset(x: 40, y: -80)
                    .rotationEffect(Angle(degrees: -2))
                
                Rectangle()
                    .frame(width: 200, height: 150)
                    .foregroundColor(.secondEmptyPhoto)
                    .shadow(radius: 10)
                    .padding()
                    .offset(x: -50, y: -60)
                    .rotationEffect(Angle(degrees: 3))
                
                ZStack{
                    Rectangle()
                        .frame(width: 200, height: 150)
                        .foregroundColor(.firstEmptyPhoto)
                        .shadow(radius: 10)
                        .padding()
                    
                    
                    Button{
//                        addInitialPhotos()
                    }label:{
                        Image(systemName: "plus")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.sweetnSour)
                    }
                    
                    
                }
                
            }
            
            Text("Choose 3 memories to start")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color(uiColor: .label))
        }
        
    }
}

#Preview {
    InitialPhotosComponent()
}
