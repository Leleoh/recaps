//
//  SlidingPuzzleViewModel.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 04/12/25.
//

import Foundation
import UIKit
import SwiftUI

@Observable
class SlidingPuzzleViewModel {
    
    let gridSize: Int = 3
    
    var tiles: [PuzzleTile] = []
    var isSolved: Bool = false
    var moveCount: Int = 0
    var timeUntilMidnight: String = "00:00:00"
    
    private var timer: Timer?
    
    init() {
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startTimer() {
        guard timer == nil else { return }
        
        updateTimeUntilMidnight()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimeUntilMidnight()
        }
    }
    
    private func updateTimeUntilMidnight() {
        guard let brazilTimeZone = TimeZone(identifier: "America/Sao_Paulo") else {
            timeUntilMidnight = "00:00:00"
            return
        }
        
        var calendar = Calendar.current
        calendar.timeZone = brazilTimeZone
        
        let currentTime = Date()
        
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentTime),
              let startOfTomorrow = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: tomorrow)) else {
            timeUntilMidnight = "00:00:00"
            return
        }
        
        let components = calendar.dateComponents([.hour, .minute, .second], from: currentTime, to: startOfTomorrow)
        
        timeUntilMidnight = String(format: "%02d:%02d:%02d",
                                   components.hour ?? 0,
                                   components.minute ?? 0,
                                   components.second ?? 0)
    }
    
    func setupGame(originalImage: UIImage) {
        self.moveCount = 0
        self.isSolved = false
        
        let squaredImage = cropToSquare(image: originalImage)
        let pieceSize = squaredImage.size.width / CGFloat(gridSize)
        var newTiles: [PuzzleTile] = []
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let index = row * gridSize + col
                
                if index == (gridSize * gridSize) - 1 {
                    newTiles.append(PuzzleTile(originalIndex: index, currentPosition: index, image: nil))
                } else {
                    let x = CGFloat(col) * pieceSize
                    let y = CGFloat(row) * pieceSize
                    let cropRect = CGRect(x: x, y: y, width: pieceSize, height: pieceSize)
                    if let cgImage = squaredImage.cgImage?.cropping(to: cropRect) {
                        let pieceImage = UIImage(cgImage: cgImage)
                        newTiles.append(PuzzleTile(originalIndex: index, currentPosition: index, image: pieceImage))
                    }
                }
            }
        }
        self.tiles = newTiles
        shuffleTiles()
    }
    
    func shuffleTiles() {
        let numberOfShuffles = 150
        
        for _ in 0..<numberOfShuffles {
            guard let emptyIndex = tiles.firstIndex(where: { $0.image == nil }) else { return }
            let neighbors = getValidNeighbors(index: emptyIndex)
            
            if let randomNeighbor = neighbors.randomElement() {
                tiles.swapAt(emptyIndex, randomNeighbor)
            }
        }
        moveCount = 0
    }
    
    func moveTile(index: Int) {
        if isSolved || tiles[index].image == nil { return }
        
        guard let emptyIndex = tiles.firstIndex(where: { $0.image == nil }) else { return }
        
        if isNeighbor(index1: index, index2: emptyIndex) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tiles.swapAt(index, emptyIndex)
            }
            moveCount += 1
            checkWinCondition()
        }
    }
    
    private func checkWinCondition() {
        let isAllCorrect = tiles.enumerated().allSatisfy { index, tile in
            return tile.originalIndex == index
        }
        
        if isAllCorrect {
            isSolved = true
        }
    }
    
    private func getValidNeighbors(index: Int) -> [Int] {
        var neighbors: [Int] = []
        let row = index / gridSize
        let col = index % gridSize
        
        if row > 0 {
            neighbors.append(index - gridSize)
        }
        
        if row < gridSize - 1 {
            neighbors.append(index + gridSize)
        }
        
        if col > 0 {
            neighbors.append(index - 1)
        }
        
        if col < gridSize - 1 {
            neighbors.append(index + 1)
        }
        
        return neighbors
    }
    
    private func isNeighbor(index1: Int, index2: Int) -> Bool {
        let row1 = index1 / gridSize
        let col1 = index1 % gridSize
        
        let row2 = index2 / gridSize
        let col2 = index2 % gridSize
        return abs(row1 - row2) + abs(col1 - col2) == 1
    }
    
    private func cropToSquare(image: UIImage) -> UIImage {
        let normalizedImage: UIImage
        if image.imageOrientation != .up {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        } else {
            normalizedImage = image
        }
        
        guard let cgImage = normalizedImage.cgImage else { return image }
        
        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)
        
        let edge = min(originalWidth, originalHeight)
        let posX = (originalWidth - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        let cropSquare = CGRect(x: posX, y: posY, width: edge, height: edge)
        
        if let croppedCGImage = cgImage.cropping(to: cropSquare) {
            return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: .up)
        }
        
        return image
    }
}
