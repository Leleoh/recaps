//
//  OpenCapsule.swift
//  recaps
//
//  Created by Ana Poletto on 25/11/25.
//

import Foundation
import SwiftUI

struct OpenCapsule: View {
    var isPink: Bool = true
    
    var body: some View {
        Image(isPink ? .openCapsulePink : .openCapsuleGreen)
    }
}

#Preview {
    OpenCapsule()
}
