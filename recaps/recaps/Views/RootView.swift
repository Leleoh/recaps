//
//  RootView.swift
//  recaps
//
//  Created by Ana Poletto on 07/12/25.
//

import SwiftUI

struct RootView: View {
    @AppStorage("userId") var userId: String = ""
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if !hasSeenOnboarding {
            Onboarding()
        } else if userId.isEmpty {
            AuthenthicationView()
        } else {
            HomeRecapsView()
        }
    }
}
