//import SwiftUI
//import UIKit
//
//
//// MARK: - 2. ViewModel
//@Observable
//class SlidingPuzzleViewModel {
//    
//    // --- MUDANÇA 1: Grid Size para 4 ---
//    let gridSize = 3
//    
//    var tiles: [PuzzleTile] = []
//    var isSolved: Bool = false
//    var moveCount: Int = 0
//    
//    func setupGame(with originalImage: UIImage) {
//        self.moveCount = 0
//        self.isSolved = false
//        
//        // Garante que a imagem é quadrada antes de começar
//        let squaredImage = cropToSquare(image: originalImage)
//        let pieceSize = squaredImage.size.width / CGFloat(gridSize)
//        var newTiles: [PuzzleTile] = []
//        
//        for row in 0..<gridSize {
//            for col in 0..<gridSize {
//                let index = row * gridSize + col
//                
//                if index == (gridSize * gridSize) - 1 {
//                    // Última peça vazia
//                    newTiles.append(PuzzleTile(originalIndex: index, currentPos: index, image: nil))
//                } else {
//                    let x = CGFloat(col) * pieceSize
//                    let y = CGFloat(row) * pieceSize
//                    let cropRect = CGRect(x: x, y: y, width: pieceSize, height: pieceSize)
//                    
//                    if let cgImage = squaredImage.cgImage?.cropping(to: cropRect) {
//                        let pieceImage = UIImage(cgImage: cgImage)
//                        newTiles.append(PuzzleTile(originalIndex: index, currentPos: index, image: pieceImage))
//                    }
//                }
//            }
//        }
//        
//        self.tiles = newTiles
//        shuffleTiles()
//    }
//    
//    func shuffleTiles() {
//        // Embaralha fazendo 150 movimentos válidos aleatórios
//        let numberOfShuffles = 150
//        
//        for _ in 0..<numberOfShuffles {
//            guard let emptyIndex = tiles.firstIndex(where: { $0.image == nil }) else { return }
//            let neighbors = getValidNeighbors(for: emptyIndex)
//            
//            if let randomNeighbor = neighbors.randomElement() {
//                // Swap simples sem animação durante o setup
//                tiles.swapAt(emptyIndex, randomNeighbor)
//            }
//        }
//        moveCount = 0
//    }
//    
//    func moveTile(at index: Int) {
//        if isSolved || tiles[index].image == nil { return }
//        
//        guard let emptyIndex = tiles.firstIndex(where: { $0.image == nil }) else { return }
//        
//        if isNeighbor(index1: index, index2: emptyIndex) {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                tiles.swapAt(index, emptyIndex)
//            }
//            moveCount += 1
//            checkWinCondition()
//        }
//    }
//    
//    private func checkWinCondition() {
//        let isAllCorrect = tiles.enumerated().allSatisfy { index, tile in
//            // Verifica se a peça que está no índice X é a peça original X
//            return tile.originalIndex == index
//        }
//        
//        if isAllCorrect {
//            isSolved = true
//        }
//    }
//    
//    private func getValidNeighbors(for index: Int) -> [Int] {
//        var neighbors: [Int] = []
//        let row = index / gridSize
//        let col = index % gridSize
//        
//        if row > 0 { neighbors.append(index - gridSize) } // Cima
//        if row < gridSize - 1 { neighbors.append(index + gridSize) } // Baixo
//        if col > 0 { neighbors.append(index - 1) } // Esquerda
//        if col < gridSize - 1 { neighbors.append(index + 1) } // Direita
//        
//        return neighbors
//    }
//    
//    private func isNeighbor(index1: Int, index2: Int) -> Bool {
//        let r1 = index1 / gridSize, c1 = index1 % gridSize
//        let r2 = index2 / gridSize, c2 = index2 % gridSize
//        return abs(r1 - r2) + abs(c1 - c2) == 1
//    }
//    
//    private func cropToSquare(image: UIImage) -> UIImage {
//        let originalWidth  = image.size.width
//        let originalHeight = image.size.height
//        let edge = min(originalWidth, originalHeight)
//        let posX = (originalWidth - edge) / 2.0
//        let posY = (originalHeight - edge) / 2.0
//        let cropSquare = CGRect(x: posX, y: posY, width: edge, height: edge)
//        
//        if let imageRef = image.cgImage?.cropping(to: cropSquare) {
//            return UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
//        }
//        return image
//    }
//}
//
//// MARK: - 3. View do Jogo
//struct SlidingPuzzleView: View {
//    @State private var viewModel = SlidingPuzzleViewModel()
//    let inputImage: UIImage
//    
//    // --- MUDANÇA 2: Definindo 4 colunas dinamicamente ---
//    // O count: 4 garante que o grid se adapte ao tamanho da ViewModel
//    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            
//            // Placar
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("Puzzle 4x4")
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                    Text("Movimentos: \(viewModel.moveCount)")
//                        .font(.title3)
//                        .bold()
//                        .monospacedDigit()
//                }
//                Spacer()
//                Button {
//                    withAnimation {
//                        viewModel.setupGame(with: inputImage)
//                    }
//                } label: {
//                    Image(systemName: "arrow.counterclockwise.circle.fill")
//                        .font(.largeTitle)
//                }
//            }
//            .padding()
//            
//            // Tabuleiro
//            ZStack {
//                // Fundo do tabuleiro (aparece onde está o espaço vazio)
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color.gray.opacity(0.2))
//                    .aspectRatio(1, contentMode: .fit)
//                
//                LazyVGrid(columns: columns, spacing: 2) {
//                    ForEach(Array(viewModel.tiles.enumerated()), id: \.element.id) { index, tile in
//                        ZStack {
//                            if let img = tile.image {
//                                Image(uiImage: img)
//                                    .resizable()
//                                    // Preenche o espaço quadrado da peça
//                                    .scaledToFill()
//                                    // Garante layout 1:1
//                                    .aspectRatio(1, contentMode: .fit)
//                                    .clipped()
//                                    .cornerRadius(4)
//                                    // Número da peça para facilitar o teste (Opcional)
//                                    .overlay(
//                                        Text("\(tile.originalIndex + 1)")
//                                            .font(.caption2)
//                                            .foregroundStyle(.white)
//                                            .padding(4)
//                                            .background(Color.black.opacity(0.5))
//                                            .clipShape(Circle())
//                                            .padding(2),
//                                        alignment: .topLeading
//                                    )
//                            } else {
//                                // Peça vazia transparente
//                                Color.clear
//                                    .aspectRatio(1, contentMode: .fit)
//                            }
//                        }
//                        .contentShape(Rectangle()) // Melhora a área de toque
//                        .onTapGesture {
//                            viewModel.moveTile(at: index)
//                        }
//                    }
//                }
//                .padding(4) // Espaçamento interno do tabuleiro
//                
//                // Overlay de Vitória
//                if viewModel.isSolved {
//                    VStack(spacing: 16) {
//                        Image(systemName: "checkmark.seal.fill")
//                            .font(.system(size: 60))
//                            .foregroundStyle(.yellow)
//                            .shadow(radius: 5)
//                        
//                        Text("Cápsula Montada!")
//                            .font(.title)
//                            .bold()
//                            .foregroundStyle(.white)
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(.black.opacity(0.75))
//                    .cornerRadius(12)
//                    .transition(.opacity)
//                }
//            }
//            .aspectRatio(1, contentMode: .fit)
//            .padding()
//            
//            Spacer()
//        }
//        .onAppear {
//            viewModel.setupGame(with: inputImage)
//        }
//    }
//}
//
//// MARK: - 4. Preview com Mock de Imagem
//#Preview {
//    // ⚠️ SUBSTITUA "NomeDaSuaImagem" pelo nome exato que está no seu Assets.xcassets
//    // O operador '??' garante que, se você errar o nome, ele usa um ícone padrão para não travar.
//    let image = UIImage(named: "monkey") ?? UIImage(systemName: "photo.artframe")!
//    
//    // Se a imagem vier rotacionada ou estranha, este método corrige a orientação
////    let fixedImage = fixOrientation(img: image)
//    
//    return SlidingPuzzleView(inputImage: image)
//}
//
//// Helper opcional para corrigir orientação se a foto do Asset estiver virada
////func fixOrientation(img: UIImage) -> UIImage {
////    if img.imageOrientation == .up { return img }
////    UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
////    img.draw(in: CGRect(origin: .zero, size: img.size))
////    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
////    UIGraphicsEndImageContext()
////    return normalizedImage
////}
