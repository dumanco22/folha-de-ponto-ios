import Foundation

/// Representa uma data (ano/mês/dia) sem hora nem fuso horário, evitando qualquer
/// ambiguidade de `Calendar`/`TimeZone` do Foundation. Toda a aritmética (soma de dias,
/// dia da semana, comparação) usa o Número de Dia Juliano (algoritmo de Fliegel & Van
/// Flandern), que é inteiro e determinístico.
struct DataSimples: Hashable, Comparable, Codable, Identifiable {
    let ano: Int
    let mes: Int   // 1...12
    let dia: Int   // 1...31

    var id: String { chaveIso }

    init(ano: Int, mes: Int, dia: Int) {
        self.ano = ano
        self.mes = mes
        self.dia = dia
    }

    /// Constrói a partir do Número de Dia Juliano.
    init(numeroJuliano jd: Int) {
        let a = jd + 32044
        let b = (4 * a + 3) / 146097
        let c = a - (146097 * b) / 4
        let d = (4 * c + 3) / 1461
        let e = c - (1461 * d) / 4
        let m = (5 * e + 2) / 153
        let dia = e - (153 * m + 2) / 5 + 1
        let mes = m + 3 - 12 * (m / 10)
        let ano = 100 * b + d - 4800 + m / 10
        self.init(ano: ano, mes: mes, dia: dia)
    }

    /// Parseia uma data no formato ISO "yyyy-MM-dd". Retorna nil se inválida.
    init?(iso: String) {
        let partes = iso.split(separator: "-")
        guard partes.count == 3,
              let a = Int(partes[0]), let m = Int(partes[1]), let d = Int(partes[2]) else {
            return nil
        }
        self.init(ano: a, mes: m, dia: d)
    }

    /// A data de hoje, segundo o calendário do aparelho.
    static func hoje() -> DataSimples {
        let componentes = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date())
        return DataSimples(ano: componentes.year ?? 1970, mes: componentes.month ?? 1, dia: componentes.day ?? 1)
    }

    var numeroJuliano: Int {
        let a = (14 - mes) / 12
        let y = ano + 4800 - a
        let m = mes + 12 * a - 3
        return dia + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
    }

    /// 0 = Domingo, 1 = Segunda, ..., 6 = Sábado (igual ao WEEKDAY() do Excel, modo padrão).
    var indiceDiaDaSemana: Int { (numeroJuliano + 1) % 7 }

    var ehFimDeSemana: Bool { indiceDiaDaSemana == 0 || indiceDiaDaSemana == 6 }

    var nomeDiaDaSemana: String {
        ["Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"][indiceDiaDaSemana]
    }

    var nomeDiaAbreviado: String {
        ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"][indiceDiaDaSemana]
    }

    var nomeMes: String {
        ["JANEIRO", "FEVEREIRO", "MARÇO", "ABRIL", "MAIO", "JUNHO",
         "JULHO", "AGOSTO", "SETEMBRO", "OUTUBRO", "NOVEMBRO", "DEZEMBRO"][mes - 1]
    }

    func adicionandoDias(_ quantidade: Int) -> DataSimples {
        DataSimples(numeroJuliano: numeroJuliano + quantidade)
    }

    /// Quantidade de dias no mês (considera anos bissextos).
    static func diasNoMes(ano: Int, mes: Int) -> Int {
        let bissexto = (ano % 4 == 0 && ano % 100 != 0) || ano % 400 == 0
        let dias = [31, bissexto ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        return dias[mes - 1]
    }

    var chaveIso: String { String(format: "%04d-%02d-%02d", ano, mes, dia) }

    var formatadaCurta: String { String(format: "%02d/%02d", dia, mes) }
    var formatadaCompleta: String { String(format: "%02d/%02d/%04d", dia, mes, ano) }

    static func < (lhs: DataSimples, rhs: DataSimples) -> Bool { lhs.numeroJuliano < rhs.numeroJuliano }
    static func == (lhs: DataSimples, rhs: DataSimples) -> Bool { lhs.numeroJuliano == rhs.numeroJuliano }
}
