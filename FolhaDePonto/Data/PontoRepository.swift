import Foundation
import SwiftData

/// Funções de acesso aos dados (SwiftData) + cálculo do período. Reunidas aqui para manter
/// as Views/ViewModels simples, mas sem esconder o `ModelContext` — cada função recebe o
/// contexto explicitamente, seguindo o padrão recomendado pela Apple para lógica fora de `@Query`.
enum PontoRepository {

    static func buscarDia(_ dataIso: String, contexto: ModelContext) -> DiaPonto? {
        let descritor = FetchDescriptor<DiaPonto>(predicate: #Predicate { $0.dataIso == dataIso })
        return (try? contexto.fetch(descritor))?.first
    }

    @discardableResult
    static func buscarOuCriarDia(_ data: DataSimples, diaInicio: Int, contexto: ModelContext) -> DiaPonto {
        if let existente = buscarDia(data.chaveIso, contexto: contexto) {
            return existente
        }
        let referencia = PeriodoUtils.referenciaParaData(data, diaInicio: diaInicio)
        let novo = DiaPonto(dataIso: data.chaveIso, periodoRef: referencia.chave)
        contexto.insert(novo)
        try? contexto.save()
        return novo
    }

    static func buscarEntidadesDoPeriodo(_ referencia: MesReferencia, contexto: ModelContext) -> [DiaPonto] {
        let chave = referencia.chave
        let descritor = FetchDescriptor<DiaPonto>(predicate: #Predicate { $0.periodoRef == chave })
        return (try? contexto.fetch(descritor)) ?? []
    }

    static func calcularPeriodo(
        _ referencia: MesReferencia,
        diaInicio: Int,
        config: ConfiguracaoData,
        contexto: ModelContext
    ) -> PeriodoResumo {
        let (inicio, fim) = PeriodoUtils.limites(referencia, diaInicio: diaInicio)
        let diasEsperados = PeriodoUtils.diasDoPeriodo(referencia, diaInicio: diaInicio)
        let entidades = buscarEntidadesDoPeriodo(referencia, contexto: contexto)
        let porData = Dictionary(uniqueKeysWithValues: entidades.map { ($0.dataIso, $0) })

        let diasCalculados = diasEsperados.map { data in
            PontoCalculator.calcularDia(data, entidade: porData[data.chaveIso], config: config)
        }

        return PontoCalculator.calcularPeriodo(
            referencia: referencia, inicio: inicio, fim: fim, dias: diasCalculados, config: config
        )
    }

    static func calcularDia(_ data: DataSimples, config: ConfiguracaoData, contexto: ModelContext) -> DiaCalculado {
        let entidade = buscarDia(data.chaveIso, contexto: contexto)
        return PontoCalculator.calcularDia(data, entidade: entidade, config: config)
    }

    static func baterPonto(_ campo: CampoPonto, data: DataSimples, diaInicio: Int, contexto: ModelContext) {
        let entidade = buscarOuCriarDia(data, diaInicio: diaInicio, contexto: contexto)
        let componentes = Calendar(identifier: .gregorian).dateComponents([.hour, .minute], from: Date())
        let horario = Horario(hora: componentes.hour ?? 0, minuto: componentes.minute ?? 0)
        entidade.definir(campo, valor: horario.textoFormatado)
        try? contexto.save()
    }

    static func salvarHorario(_ campo: CampoPonto, valor: Horario?, data: DataSimples, diaInicio: Int, contexto: ModelContext) {
        let entidade = buscarOuCriarDia(data, diaInicio: diaInicio, contexto: contexto)
        entidade.definir(campo, valor: valor?.textoFormatado)
        try? contexto.save()
    }

    static func salvarFolga(_ valor: Bool, data: DataSimples, diaInicio: Int, contexto: ModelContext) {
        let entidade = buscarOuCriarDia(data, diaInicio: diaInicio, contexto: contexto)
        entidade.folga = valor
        try? contexto.save()
    }

    static func salvarIfood(_ valor: Bool, data: DataSimples, diaInicio: Int, contexto: ModelContext) {
        let entidade = buscarOuCriarDia(data, diaInicio: diaInicio, contexto: contexto)
        entidade.ifood = valor
        try? contexto.save()
    }

    static func salvarObservacao(_ texto: String, data: DataSimples, diaInicio: Int, contexto: ModelContext) {
        let entidade = buscarOuCriarDia(data, diaInicio: diaInicio, contexto: contexto)
        entidade.observacao = texto.isEmpty ? nil : texto
        try? contexto.save()
    }
}
