import Foundation

/// Identifica um período pelo mês em que ele COMEÇA (ex.: período 24/08 a 23/09
/// é o período de referência "AGOSTO/2026"), assim como o "Mês de referência" da planilha.
struct MesReferencia: Hashable, Comparable, Codable {
    let ano: Int
    let mes: Int // 1...12

    var chave: String { String(format: "%04d-%02d", ano, mes) }

    static func atual(diaInicio: Int) -> MesReferencia {
        PeriodoUtils.referenciaParaData(DataSimples.hoje(), diaInicio: diaInicio)
    }

    func adicionandoMeses(_ quantidade: Int) -> MesReferencia {
        let totalMeses = ano * 12 + (mes - 1) + quantidade
        let novoAno = totalMeses / 12
        let novoMes = totalMeses % 12 + 1
        return MesReferencia(ano: novoAno, mes: novoMes)
    }

    var nomeMes: String {
        ["JANEIRO", "FEVEREIRO", "MARÇO", "ABRIL", "MAIO", "JUNHO",
         "JULHO", "AGOSTO", "SETEMBRO", "OUTUBRO", "NOVEMBRO", "DEZEMBRO"][mes - 1]
    }

    var titulo: String { "\(nomeMes)/\(ano)" }

    static func < (lhs: MesReferencia, rhs: MesReferencia) -> Bool {
        if lhs.ano != rhs.ano { return lhs.ano < rhs.ano }
        return lhs.mes < rhs.mes
    }
}
