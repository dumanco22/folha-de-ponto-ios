import Foundation
import SwiftData

@MainActor
final class InicioViewModel: ObservableObject {
    @Published var carregando = true
    @Published var resumo: PeriodoResumo?
    @Published var proximaAcao: CampoPonto?
    @Published var ehPeriodoAtual = true

    private var referenciaSelecionada: MesReferencia?

    func carregar(contexto: ModelContext, config: ConfiguracaoData) {
        let hoje = DataSimples.hoje()
        let referenciaAtual = PeriodoUtils.referenciaParaData(hoje, diaInicio: config.diaInicioPeriodo)
        let referencia = referenciaSelecionada ?? referenciaAtual

        let resumoCalculado = PontoRepository.calcularPeriodo(
            referencia, diaInicio: config.diaInicioPeriodo, config: config, contexto: contexto
        )
        let diaHoje = resumoCalculado.dias.first { $0.data == hoje }

        resumo = resumoCalculado
        proximaAcao = diaHoje?.proximaAcao
        ehPeriodoAtual = referencia == referenciaAtual
        carregando = false
    }

    func periodoAnterior(contexto: ModelContext, config: ConfiguracaoData) {
        let atual = resumo?.referencia ?? PeriodoUtils.referenciaParaData(DataSimples.hoje(), diaInicio: config.diaInicioPeriodo)
        referenciaSelecionada = atual.adicionandoMeses(-1)
        carregar(contexto: contexto, config: config)
    }

    func periodoSeguinte(contexto: ModelContext, config: ConfiguracaoData) {
        let atual = resumo?.referencia ?? PeriodoUtils.referenciaParaData(DataSimples.hoje(), diaInicio: config.diaInicioPeriodo)
        referenciaSelecionada = atual.adicionandoMeses(1)
        carregar(contexto: contexto, config: config)
    }

    func voltarAoPeriodoAtual(contexto: ModelContext, config: ConfiguracaoData) {
        referenciaSelecionada = nil
        carregar(contexto: contexto, config: config)
    }

    func baterPonto(contexto: ModelContext, config: ConfiguracaoData) {
        guard let campo = proximaAcao else { return }
        PontoRepository.baterPonto(campo, data: DataSimples.hoje(), diaInicio: config.diaInicioPeriodo, contexto: contexto)
        carregar(contexto: contexto, config: config)
    }
}
