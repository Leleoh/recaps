//
//  PuzzleComponent.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 05/12/25.
//

import SwiftUI


struct PuzzleTileView: View {
    let tile: PuzzleTile
    
    var body: some View {
        ZStack {
            if let img = tile.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
                    .cornerRadius(4)
                    .overlay(
                        Text("\(tile.originalIndex + 1)")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .padding(2),
                        alignment: .topLeading
                    )
            } else {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .contentShape(Rectangle())
    }
}

struct SlidingPuzzleComponent: View {
    @State private var viewModel = SlidingPuzzleViewModel()
    let image: UIImage
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    
    var body: some View {
        VStack {
            
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("Sliding Puzzle")
//                        .font(.largeTitle)
//                        .bold()
//                    
//                    Text("Movimentos: \(viewModel.moveCount)")
//                        .font(.title2)
//                        .monospacedDigit()
//                }
//                
//                Spacer()
//                
//                Button {
//                    withAnimation {
//                        viewModel.setupGame(originalImage: image)
//                    }
//                } label: {
//                    Image(systemName: "arrow.counterclockwise.circle.fill")
//                        .font(.system(size: 40))
//                }
//            }
//            .padding()
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                
                LazyVGrid(columns: columns, spacing: 2) {

                    ForEach(Array(viewModel.tiles.enumerated()), id: \.element.id) { index, tile in
                        PuzzleTileView(tile: tile)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    viewModel.moveTile(index: index)
                                }
                            }
                    }
                }
                .padding(4)
                
                if viewModel.isSolved {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.green)
                            .shadow(radius: 5)
                        
                        Text("Memória concluída!")
                            .font(.title)
                            .bold()
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black.opacity(0.75))
                    .cornerRadius(12)
                    .transition(.opacity)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .padding()
            
            Spacer()
        }
        .onAppear {
            viewModel.setupGame(originalImage: image)
        }
    }
}

#Preview {
    let mockImage = UIImage(named: "imagem3") ?? UIImage()
    return SlidingPuzzleComponent(image: mockImage)
}



