import Foundation

/// Um horário do dia (hora:minuto), sem data nem fuso — evita qualquer ambiguidade de
/// `Date`/`Calendar` ao lidar apenas com "que horas são", como a planilha original.
struct Horario: Hashable, Comparable, Codable {
    let hora: Int    // 0...23
    let minuto: Int  // 0...59

    init(hora: Int, minuto: Int) {
        self.hora = hora
        self.minuto = minuto
    }

    /// Parseia texto no formato "HH:mm". Retorna nil se inválido ou vazio.
    init?(texto: String?) {
        guard let texto, !texto.isEmpty else { return nil }
        let partes = texto.split(separator: ":")
        guard partes.count == 2, let h = Int(partes[0]), let m = Int(partes[1]),
              h >= 0, h <= 23, m >= 0, m <= 59 else { return nil }
        self.init(hora: h, minuto: m)
    }

    var minutosDesdeMeiaNoite: Int { hora * 60 + minuto }

    var textoFormatado: String { String(format: "%02d:%02d", hora, minuto) }

    static func < (lhs: Horario, rhs: Horario) -> Bool { lhs.minutosDesdeMeiaNoite < rhs.minutosDesdeMeiaNoite }
    static func == (lhs: Horario, rhs: Horario) -> Bool { lhs.minutosDesdeMeiaNoite == rhs.minutosDesdeMeiaNoite }
}

/// Uma duração em minutos (sempre >= 0 neste app). Equivalente ao `Duration` usado no
/// motor de cálculo, mas expresso de forma simples como inteiro de minutos.
struct Duracao: Hashable, Comparable, Codable {
    let minutos: Int

    static let zero = Duracao(minutos: 0)

    static func entre(_ inicio: Horario, _ fim: Horario) -> Duracao {
        var diferenca = fim.minutosDesdeMeiaNoite - inicio.minutosDesdeMeiaNoite
        if diferenca < 0 { diferenca += 24 * 60 } // segurança para turnos que cruzam a meia-noite
        return Duracao(minutos: diferenca)
    }

    static func + (lhs: Duracao, rhs: Duracao) -> Duracao { Duracao(minutos: lhs.minutos + rhs.minutos) }

    static func - (lhs: Duracao, rhs: Duracao) -> Duracao {
        Duracao(minutos: max(0, lhs.minutos - rhs.minutos))
    }

    static func < (lhs: Duracao, rhs: Duracao) -> Bool { lhs.minutos < rhs.minutos }
    static func == (lhs: Duracao, rhs: Duracao) -> Bool { lhs.minutos == rhs.minutos }

    var horas: Int { minutos / 60 }
    var minutosRestantes: Int { minutos % 60 }
    var emHorasDecimais: Double { Double(minutos) / 60.0 }

    var textoFormatado: String { minutos > 0 ? String(format: "%dh%02d", horas, minutosRestantes) : "0h00" }
}
