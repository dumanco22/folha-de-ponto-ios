import Foundation

/// Configuração editável pelo usuário na tela de Configurações.
/// Os valores padrão replicam exatamente a planilha original (Horas.xlsx).
struct ConfiguracaoData: Codable, Equatable {
    // Dados do funcionário / empresa (para exibição e PDF)
    var nomeFuncionario: String = "DANRLEY"
    var cargoMatricula: String = "LIDER EXPEDIÇÃO"
    var empresa: String = "SUNNY BRINQUEDOS"

    // Horários padrão previstos (HH:mm)
    var segQuiEntrada: String = "07:40"
    var segQuiSaida: String = "17:30"
    var sextaEntrada: String = "07:40"
    var sextaSaida: String = "17:10"
    var sabadoEntrada: String = "17:30"
    var sabadoSaida: String = "22:00"
    var domingoEntrada: String = "07:30"
    var domingoSaida: String = "13:00"
    var almocoSaida: String = "12:00"
    var almocoRetorno: String = "13:00"

    // Valores em R$
    var valorHoraNormal: Double = 16.0
    var valorFolga: Double = 118.0
    var valorIfoodDia: Double = 33.0

    // Dia em que o período começa (planilha: dia 24; fecha no dia 23 do mês seguinte)
    var diaInicioPeriodo: Int = 24

    var valorHoraExtra60: Double { valorHoraNormal * 1.6 }
    var valorHoraExtra100: Double { valorHoraNormal * 2.0 }
}
