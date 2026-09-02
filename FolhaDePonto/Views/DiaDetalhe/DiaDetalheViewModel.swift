import Foundation
import SwiftData

@MainActor
final class DiaDetalheViewModel: ObservableObject {
    @Published var dia: DiaCalculado?
    @Published var config: ConfiguracaoData = ConfiguracaoData()

    private var dataAtual: DataSimples?

    func carregar(dataIso: String, contexto: ModelContext, config: ConfiguracaoData) {
        guard let data = DataSimples(iso: dataIso) else { return }
        dataAtual = data
        self.config = config
        dia = PontoRepository.calcularDia(data, config: config, contexto: contexto)
    }

    private func recarregar(contexto: ModelContext) {
        guard let data = dataAtual else { return }
        dia = PontoRepository.calcularDia(data, config: config, contexto: contexto)
    }

    func salvarHorario(_ campo: CampoPonto, valor: Horario?, contexto: ModelContext) {
        guard let data = dataAtual else { return }
        PontoRepository.salvarHorario(campo, valor: valor, data: data, diaInicio: config.diaInicioPeriodo, contexto: contexto)
        recarregar(contexto: contexto)
    }

    func alternarFolga(_ valor: Bool, contexto: ModelContext) {
        guard let data = dataAtual else { return }
        PontoRepository.salvarFolga(valor, data: data, diaInicio: config.diaInicioPeriodo, contexto: contexto)
        recarregar(contexto: contexto)
    }

    func alternarIfood(_ valor: Bool, contexto: ModelContext) {
        guard let data = dataAtual else { return }
        PontoRepository.salvarIfood(valor, data: data, diaInicio: config.diaInicioPeriodo, contexto: contexto)
        recarregar(contexto: contexto)
    }

    func salvarObservacao(_ texto: String, contexto: ModelContext) {
        guard let data = dataAtual else { return }
        PontoRepository.salvarObservacao(texto, data: data, diaInicio: config.diaInicioPeriodo, contexto: contexto)
        recarregar(contexto: contexto)
    }
}
