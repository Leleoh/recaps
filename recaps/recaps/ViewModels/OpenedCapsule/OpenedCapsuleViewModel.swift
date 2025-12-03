//
//  OpenedCapsuleViewModel.swift
//  recaps
//
//  Created by Leonel Ferraz Hernandez on 02/12/25.
//

import Foundation
import Observation

@Observable
class OpenedCapsuleViewModel{
    
    var submissions: [Submission] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let capsuleService: CapsuleServiceProtocol
    
    init(capsuleService: CapsuleServiceProtocol = CapsuleService()) {
            self.capsuleService = capsuleService
        }
    
    @MainActor
    func fetchSubmissions(for capsuleID: UUID) async{
        isLoading = true
        errorMessage = nil
        do{
            print("Buscando submissions para a cápsula \(capsuleID)")
            let result = try await capsuleService.fetchSubmissions(capsuleID: capsuleID)
            
            self.submissions = result
            isLoading = false
//            self.submissions = result.sorted(by: { $0.date > $1.date })
        }catch{
            print("Erro ao buscar submissions: \(error)")
            errorMessage = "Erro ao carregar memórias."
            isLoading = false
        }
            
    }
    
    
    
}
