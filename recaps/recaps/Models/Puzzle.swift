//
//  Puzzle.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 04/12/25.
//

import Foundation
import SwiftUI

struct PuzzleTile: Identifiable, Equatable {
    let id: UUID = UUID()
    let originalIndex: Int
    var currentPosition: Int
    let image: UIImage?
}
