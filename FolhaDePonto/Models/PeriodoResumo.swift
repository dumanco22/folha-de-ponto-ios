import Foundation

/// Resumo/totais de um período completo (dia de início até dia de fechamento),
/// equivalente à linha "TOTAL DO PERÍODO" + "CÁLCULO DE VALORES" da planilha.
struct PeriodoResumo {
    let referencia: MesReferencia
    let inicio: DataSimples
    let fim: DataSimples
    let dias: [DiaCalculado]
    let totalTrabalhadas: Duracao
    let totalNormais: Duracao
    let totalExtra60: Duracao
    let totalExtra100: Duracao
    let quantidadeFolgas: Int
    let quantidadeIfood: Int
    let valorFolgas: Double
    let valorIfood: Double
    let valorExtra60: Double
    let valorExtra100: Double
    let totalGeralExtras: Double

    var tituloPeriodo: String { referencia.titulo }
}
