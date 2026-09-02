import Foundation

enum Formatadores {
    private static let localePtBR = Locale(identifier: "pt_BR")

    private static let formatoMoeda: NumberFormatter = {
        let formatador = NumberFormatter()
        formatador.numberStyle = .currency
        formatador.locale = localePtBR
        return formatador
    }()

    static func moeda(_ valor: Double) -> String {
        formatoMoeda.string(from: NSNumber(value: valor)) ?? String(format: "R$ %.2f", valor)
    }
}
