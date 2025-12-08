//
//  RootView.swift
//  recaps
//
//  Created by Ana Poletto on 07/12/25.
//

import SwiftUI

struct RootView: View {
    @AppStorage("userId") var userId: String = ""
    
    var body: some View {
        if userId.isEmpty {
            AuthenthicationView()
        } else {
            HomeRecapsView()
        }
    }
}
