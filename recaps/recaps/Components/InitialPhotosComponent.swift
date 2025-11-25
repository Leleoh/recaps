//
//  InitialPhotosComponent.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 25/11/25.
//

import SwiftUI

struct InitialPhotosComponent: View {
    var body: some View {
        
        ZStack{
            Rectangle()
                .frame(width: 200, height: 150)
                .foregroundColor(.red)
                .shadow(radius: 10)
                .padding()
                .offset(x: 40, y: -80)
                .rotationEffect(Angle(degrees: -2))
            
            Rectangle()
                .frame(width: 200, height: 150)
                .foregroundColor(.blue)
                .shadow(radius: 10)
                .padding()
                .offset(x: -50, y: -60)
                .rotationEffect(Angle(degrees: 3))
            
            ZStack{
                Rectangle()
                    .frame(width: 200, height: 150)
                    .foregroundColor(.green)
                    .shadow(radius: 10)
                    .padding()
                
                Image(systemName: "plus")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.sweetnSour)
            }
        }
        
    }
}

#Preview {
    InitialPhotosComponent()
}
