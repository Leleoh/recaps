import SwiftUI
import CloudKit

struct CKUsabilityView: View {
    @State private var phrase: String = ""
    @State private var createdID = UUID()
    
    @State private var message: String = ""
    
    
    private let CKService = CapsuleService()

    var body: some View {
        let mockId = UUID()

        let mockUser = User(
            id: "mock-user-id",
            name: "Leonel Hernandez",
            email: "leonel@example.com",
            capsules: [mockId]
        )
        let mockCapsule = Capsule(
            id: createdID,
            code: "A7K4Q",
            submissions: [],
            name: "Festa de Reveillon 2025",
            createdAt: Date(),
            offensive: 0,
            lastSubmissionDate: Date(),
            validOffensive: true,
            lives: 3,
            members: [mockUser.id],
            ownerId: mockUser.id,
            status: .inProgress
        )
        let mockCapsuleUpdate = Capsule(
            id: createdID,
            code: "MORRALEONEL",
            submissions: [],
            name: "Festa de Reveillon 2025",
            createdAt: Date(),
            offensive: 0,
            lastSubmissionDate: Date(),
            validOffensive: true,
            lives: 3,
            members: [mockUser.id],
            ownerId: mockUser.id,
            status: .inProgress
        )
        let mockSubmission = Submission(
            id: UUID(),
            imageURL: nil,
            description: "A vida é curta, vive cada momento!",
            authorId: mockUser.id,
            date: Date(),
            capsuleID: createdID
        )
        let idsToFetch: [UUID] = [
            UUID(uuidString: "116AF188-382F-4F93-8F4C-572E0015ADA1")
        ].compactMap { $0 }
        
        VStack(spacing: 20) {

            Button {
                Task {
                    do {
                        let capsules = try await CKService.fetchCapsules(IDs: idsToFetch)
                        let id = capsules.first?.id ?? nil
                        let lastSubmissionDate = capsules.first?.lastSubmissionDate
                        
                        print("Capsula ID: \(id) \n LastSubmission: \(lastSubmissionDate)")
                    } catch {
                        print("Erro ao buscar cápsula: \(error)")
                    }
                }
            } label: {
                Text("Buscar Capsula")
            }
            .buttonStyle(.borderedProminent)
    
            Button {
    
                Task {
                    do {
                        try await CKService.updateLastSubmissionDate(capsuleID: idsToFetch.first!)
                        let capsules = try await CKService.fetchCapsules(IDs: idsToFetch)
                        let id = capsules.first?.id ?? nil
                        let lastSubmissionDate = capsules.first?.lastSubmissionDate
                        print("Atualizado!")
                        print("Capsula ID: \(id) \n LastSubmission: \(lastSubmissionDate)")
                        await MainActor.run {
                            message = "Capsula atualizada com sucesso! \n\(mockCapsule)"
                        }
                    } catch {
                        await MainActor.run {
                            message = "Erro ao atualizar last submissiond a capsula: \(error.localizedDescription)"
                        }
                    }
                }
            } label: {
                Text("Atualizar Cápsula")
            }
            .buttonStyle(.borderedProminent)
            

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.gray)
            }

            Spacer()
            
        }
        .padding()
    }

    // MARK: - Função CloudKit
    func savePhrase(_ phrase: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let container = CKContainer(identifier: "iCloud.com.Recaps.app")
        let database = container.publicCloudDatabase

        let record = CKRecord(recordType: "Phrase")
        record["text"] = phrase as CKRecordValue

        database.save(record) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
