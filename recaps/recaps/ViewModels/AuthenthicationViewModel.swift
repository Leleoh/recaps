//
//  AuthViewModel.swift
//  SignInWithApple
//
//  Created by Ana Carolina Poletto on 18/11/25.
//

import AuthenticationServices
import SwiftUI

@Observable
class AuthenthicationViewModel {
    var isSignedIn = false
    var email: String = ""
    var userId: String = ""
    var name: String = ""
    
    
    func handleAuthResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            
            self.email = credential.email ?? ""
            self.userId = credential.user
            self.name = credential.fullName?.givenName ?? ""
            
            DispatchQueue.main.async {
                self.isSignedIn = true
            }
            
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func checkExistingAccount() {
        if !userId.isEmpty {
            isSignedIn = true
        }
    }
}

import CloudKit

extension AuthenthicationViewModel {
    func fetchUserFromCloud(completion: @escaping (User?) -> Void) {
        let container = CKContainer(identifier: "iCloud.com.Recaps.app")
        let database = container.publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: userId)
        
        database.fetch(withRecordID: recordID) { record, error in
            if let _ = error {
                completion(nil)
                return
            }
            
            guard let record = record else {
                completion(nil)
                return
            }
            
            let name = record["name"] as? String ?? ""
            let email = record["email"] as? String ?? ""
            
            let user = User(id: self.userId, name: name, email: email, capsulesIDs: [])
            completion(user)
        }
    }
    
    func createUserInCloud(completion: @escaping (Result<Void, Error>) -> Void) {
        let container = CKContainer(identifier: "iCloud.com.Recaps.app")
        let database = container.publicCloudDatabase
        
        let recordID = CKRecord.ID(recordName: userId)
        let record = CKRecord(recordType: "User", recordID: recordID)
        
        record["email"] = email as CKRecordValue
        record["name"] = name as CKRecordValue
        
        
        database.save(record) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

