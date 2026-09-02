import SwiftUI
import SwiftData

@main
struct FolhaDePontoApp: App {
    @StateObject private var configuracaoStore = ConfiguracaoStore()

    var container: ModelContainer = {
        let esquema = Schema([DiaPonto.self])
        let configuracaoModelo = ModelConfiguration(schema: esquema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: esquema, configurations: [configuracaoModelo])
        } catch {
            fatalError("Não foi possível criar o banco de dados local: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            InicioView()
                .environmentObject(configuracaoStore)
        }
        .modelContainer(container)
    }
}
