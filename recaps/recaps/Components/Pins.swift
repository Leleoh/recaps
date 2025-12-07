//
//  Pins.swift
//  recaps
//
//  Created by Ana Poletto on 06/12/25.
//

import SwiftUI

struct Pins: View {
    var pin: Int?
    var body: some View {
        let finalPin = pin ?? Int.random(in: 1...5)
        Image("pin\(finalPin)")
    }
}

#Preview {
    VStack {
        Pins(pin: 1)
        Pins()
    }
}
