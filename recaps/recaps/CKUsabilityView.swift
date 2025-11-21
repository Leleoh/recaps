import SwiftUI
import CloudKit

struct CKUsabilityView: View {
    @State private var phrase: String = ""
    @State private var createdID = UUID()
    
    @State private var message: String = ""
    
    private let CKService = CloudKitService()

    var body: some View {
        let mockUser = User(
            id: UUID(),
            name: "Leonel Hernandez",
            mail: "leonel@example.com",
            capsulesIDs: [UUID()]
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
        
        VStack(spacing: 20) {
            TextField("Digite uma frase...", text: $phrase)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button {
                Task {
                    do {
                        try await CKService.createCapsule(capsule: mockCapsule)
                        await MainActor.run {
                            message = "Capsula salva com sucesso! \n\(mockCapsule)"
                        }
                    } catch {
                        await MainActor.run {
                            message = "Erro ao salvar a capsula: \(error.localizedDescription)"
                        }
                    }
                }
            } label: {
                Text("Salvar no CloudKit")
            }
            .buttonStyle(.borderedProminent)
    
            Button {
    
                Task {
                    do {
                        try await CKService.deleteCapsule(capsuleID: createdID)
                        await MainActor.run {
                            message = "Capsula deletado com sucesso! \n\(mockCapsule)"
                        }
                    } catch {
                        await MainActor.run {
                            message = "Erro ao deletar a capsula: \(error.localizedDescription)"
                        }
                    }
                }
            } label: {
                Text("Deletar Cápsula")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
    
                Task {
                    do {
                        try await CKService.updateCapsule(capsule: mockCapsuleUpdate)
                        await MainActor.run {
                            message = "Capsula atualizada com sucesso! \n\(mockCapsuleUpdate)"
                        }
                    } catch {
                        await MainActor.run {
                            message = "Erro ao atualizar a capsula: \(error.localizedDescription)"
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
