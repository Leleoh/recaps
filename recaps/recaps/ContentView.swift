import SwiftUI
import CloudKit

struct ContentView: View {
    @State private var phrase: String = ""
    @State private var message: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Digite uma frase...", text: $phrase)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button("Salvar no CloudKit") {
                savePhrase(phrase) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            message = "Frase salva com sucesso!"
                            phrase = ""
                        case .failure(let error):
                            message = "Erro: \(error.localizedDescription)"
                        }
                    }
                }
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
