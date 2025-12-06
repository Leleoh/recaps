//
//  Pins.swift
//  recaps
//
//  Created by Ana Poletto on 06/12/25.
//

import SwiftUI

struct Pins: View {
    private let pin: String = "pin\(Int.random(in: 1...5))"
    
    var body: some View {
        Image(pin)
    }
}

#Preview {
    Pins()
}
