//
//  HomeRecapsViewModel.swift
//  recaps
//
//  Created by Richard Fagundes Rodrigues on 19/11/25.
//

import Foundation
import SwiftUI

@Observable
class HomeRecapsViewModel: HomeRecapsViewModelProtocol {
    
    var showCreateCapsule: Bool = false
    
    func didTapNewRecap() {
        showCreateCapsule = true
    }
}
