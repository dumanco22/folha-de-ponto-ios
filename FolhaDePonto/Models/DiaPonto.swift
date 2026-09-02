import Foundation
import SwiftData

/// Campo do ponto que pode ser "batido".
enum CampoPonto: String, Codable {
    case entrada, saidaAlmoco, retornoAlmoco, saida
}

/// Um dia dentro de um período de folha de ponto, persistido localmente.
/// Os horários "previstos" NÃO são armazenados aqui: são calculados a partir da
/// configuração (dia da semana + horários padrão), assim como na planilha original.
/// Apenas os horários "reais" batidos/editados pelo usuário são persistidos.
@Model
final class DiaPonto {
    @Attribute(.unique) var dataIso: String // "yyyy-MM-dd"
    var periodoRef: String                  // "yyyy-MM" = mês de referência do período
    var entradaReal: String?                // "HH:mm"
    var saidaAlmoco: String?
    var retornoAlmoco: String?
    var saidaReal: String?
    var folga: Bool
    var ifood: Bool
    var observacao: String?

    init(
        dataIso: String,
        periodoRef: String,
        entradaReal: String? = nil,
        saidaAlmoco: String? = nil,
        retornoAlmoco: String? = nil,
        saidaReal: String? = nil,
        folga: Bool = false,
        ifood: Bool = false,
        observacao: String? = nil
    ) {
        self.dataIso = dataIso
        self.periodoRef = periodoRef
        self.entradaReal = entradaReal
        self.saidaAlmoco = saidaAlmoco
        self.retornoAlmoco = retornoAlmoco
        self.saidaReal = saidaReal
        self.folga = folga
        self.ifood = ifood
        self.observacao = observacao
    }

    func horario(para campo: CampoPonto) -> String? {
        switch campo {
        case .entrada: return entradaReal
        case .saidaAlmoco: return saidaAlmoco
        case .retornoAlmoco: return retornoAlmoco
        case .saida: return saidaReal
        }
    }

    func definir(_ campo: CampoPonto, valor: String?) {
        switch campo {
        case .entrada: entradaReal = valor
        case .saidaAlmoco: saidaAlmoco = valor
        case .retornoAlmoco: retornoAlmoco = valor
        case .saida: saidaReal = valor
        }
    }
}
