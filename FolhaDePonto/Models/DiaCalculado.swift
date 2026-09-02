import Foundation

/// Representa um dia já calculado do período: horários previstos (derivados da
/// configuração + dia da semana) + horários reais (persistidos) + horas calculadas.
struct DiaCalculado: Identifiable, Hashable {
    let data: DataSimples
    let entradaPrevista: Horario
    let saidaPrevista: Horario
    let entradaReal: Horario?
    let saidaAlmoco: Horario?
    let retornoAlmoco: Horario?
    let saidaReal: Horario?
    let folga: Bool
    let ifood: Bool
    let observacao: String?
    let horasTrabalhadas: Duracao
    let horasNormais: Duracao
    let horasExtra60: Duracao
    let horasExtra100: Duracao

    var id: String { data.chaveIso }

    var fimDeSemana: Bool { data.ehFimDeSemana }

    var registroCompleto: Bool { entradaReal != nil && saidaReal != nil }

    /// Qual é o próximo campo a bater ponto neste dia (nil = já completo).
    var proximaAcao: CampoPonto? {
        if entradaReal == nil { return .entrada }
        if !fimDeSemana && saidaAlmoco == nil { return .saidaAlmoco }
        if !fimDeSemana && retornoAlmoco == nil { return .retornoAlmoco }
        if saidaReal == nil { return .saida }
        return nil
    }
}
