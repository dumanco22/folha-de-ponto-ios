import Foundation
import Combine

/// Guarda a configuração do usuário localmente (UserDefaults), como o DataStore no Android.
@MainActor
final class ConfiguracaoStore: ObservableObject {
    @Published private(set) var config: ConfiguracaoData

    private let chaveArmazenamento = "configuracao_folha_de_ponto"

    init() {
        if let dados = UserDefaults.standard.data(forKey: chaveArmazenamento),
           let decodificada = try? JSONDecoder().decode(ConfiguracaoData.self, from: dados) {
            config = decodificada
        } else {
            config = ConfiguracaoData()
        }
    }

    func salvar(_ nova: ConfiguracaoData) {
        config = nova
        if let dados = try? JSONEncoder().encode(nova) {
            UserDefaults.standard.set(dados, forKey: chaveArmazenamento)
        }
    }
}
