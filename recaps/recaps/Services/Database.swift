//
//  Database.swift
//  recaps
//
//  Created by Ana Carolina Poletto on 21/11/25.
//

import CloudKit
import SwiftUI

class Database {
    static let shared = Database()
    
    let container: CKContainer
    let database: CKDatabase

    init() {
        container = CKContainer(identifier: "iCloud.com.Recaps.app")
        database = container.publicCloudDatabase
    }
}
