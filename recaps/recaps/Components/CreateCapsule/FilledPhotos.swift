//
//  FilledPhotos.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 27/11/25.
//

import SwiftUI

struct FilledPhotos: View {
    // Array de imagens que virá da seleção anterior
    var images: [UIImage]
    
    var body: some View {
//        VStack {
            ZStack {
                //Fundo
                if images.indices.contains(2) {
                    PhotoCardView(image: images[2])
                        .offset(x: 10, y: -140)
                        .rotationEffect(Angle(degrees: -2))
                }
                
                //Meio
                if images.indices.contains(1) {
                    PhotoCardView(image: images[1])
                        .offset(x: -50, y: -40)
                        .rotationEffect(Angle(degrees: 3))
                }
                
                //Frente
                if images.indices.contains(0) {
                    PhotoCardView(image: images[0])
                        .offset(x: 0, y: 60)

                }
            }
//        }
    }
}

//Componente auxiliar
private struct PhotoCardView: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 200, height: 150)
            .clipped()
            .shadow(radius: 10)
            .padding()
    }
}

#Preview {
    FilledPhotos(images: [
        UIImage(named: "imagem1")!,
        UIImage(named: "imagem2")!,
        UIImage(named: "imagem3")!
    ])
}
