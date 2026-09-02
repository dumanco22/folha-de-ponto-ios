import Foundation

/// Motor de cálculo que replica fielmente as fórmulas da planilha Horas.xlsx:
///
///  Horas Trabalhadas = (SaídaReal - EntradaReal) - (RetornoAlmoço - SaídaAlmoço)
///  Se sábado/domingo:
///      Horas Normais = 0
///      Extra 60%     = 0
///      Extra 100%    = Horas Trabalhadas
///  Senão (dia de semana):
///      capNormal     = (SaídaPrevista - EntradaPrevista) - 1h  (janela prevista menos 1h de almoço fixo)
///      Horas Normais = MIN(HorasTrabalhadas, capNormal)
///      Extra 60%     = MAX(0, HorasTrabalhadas - capNormal)
///      Extra 100%    = 0
enum PontoCalculator {

    static func previstoParaDia(_ data: DataSimples, config: ConfiguracaoData) -> (entrada: Horario, saida: Horario) {
        switch data.indiceDiaDaSemana {
        case 1, 2, 3, 4: // Segunda a Quinta
            return (Horario(texto: config.segQuiEntrada) ?? Horario(hora: 7, minuto: 40),
                    Horario(texto: config.segQuiSaida) ?? Horario(hora: 17, minuto: 30))
        case 5: // Sexta
            return (Horario(texto: config.sextaEntrada) ?? Horario(hora: 7, minuto: 40),
                    Horario(texto: config.sextaSaida) ?? Horario(hora: 17, minuto: 10))
        case 6: // Sábado
            return (Horario(texto: config.sabadoEntrada) ?? Horario(hora: 17, minuto: 30),
                    Horario(texto: config.sabadoSaida) ?? Horario(hora: 22, minuto: 0))
        default: // Domingo (0)
            return (Horario(texto: config.domingoEntrada) ?? Horario(hora: 7, minuto: 30),
                    Horario(texto: config.domingoSaida) ?? Horario(hora: 13, minuto: 0))
        }
    }

    static func calcularDia(_ data: DataSimples, entidade: DiaPonto?, config: ConfiguracaoData) -> DiaCalculado {
        let (entradaPrevista, saidaPrevista) = previstoParaDia(data, config: config)

        let entradaReal = Horario(texto: entidade?.entradaReal)
        let saidaAlmoco = Horario(texto: entidade?.saidaAlmoco)
        let retornoAlmoco = Horario(texto: entidade?.retornoAlmoco)
        let saidaReal = Horario(texto: entidade?.saidaReal)
        let folga = entidade?.folga ?? false
        let ifood = entidade?.ifood ?? false

        var trabalhado: Duracao? = nil
        if let entradaReal, let saidaReal {
            let bruto = Duracao.entre(entradaReal, saidaReal)
            let almoco: Duracao
            if let saidaAlmoco, let retornoAlmoco {
                almoco = Duracao.entre(saidaAlmoco, retornoAlmoco)
            } else {
                almoco = .zero
            }
            trabalhado = bruto - almoco
        }

        var horasNormais = Duracao.zero
        var horasExtra60 = Duracao.zero
        var horasExtra100 = Duracao.zero

        if let trabalhado {
            if data.ehFimDeSemana {
                horasExtra100 = trabalhado
            } else {
                let janela = Duracao.entre(entradaPrevista, saidaPrevista)
                let cap = janela - Duracao(minutos: 60)
                horasNormais = trabalhado < cap ? trabalhado : cap
                horasExtra60 = trabalhado > cap ? (trabalhado - cap) : .zero
            }
        }

        return DiaCalculado(
            data: data,
            entradaPrevista: entradaPrevista,
            saidaPrevista: saidaPrevista,
            entradaReal: entradaReal,
            saidaAlmoco: saidaAlmoco,
            retornoAlmoco: retornoAlmoco,
            saidaReal: saidaReal,
            folga: folga,
            ifood: ifood,
            observacao: entidade?.observacao,
            horasTrabalhadas: trabalhado ?? .zero,
            horasNormais: horasNormais,
            horasExtra60: horasExtra60,
            horasExtra100: horasExtra100
        )
    }

    static func calcularPeriodo(
        referencia: MesReferencia,
        inicio: DataSimples,
        fim: DataSimples,
        dias: [DiaCalculado],
        config: ConfiguracaoData
    ) -> PeriodoResumo {
        var totalTrabalhadas = Duracao.zero
        var totalNormais = Duracao.zero
        var totalExtra60 = Duracao.zero
        var totalExtra100 = Duracao.zero
        var qtdFolgas = 0
        var qtdIfood = 0

        for dia in dias {
            totalTrabalhadas = totalTrabalhadas + dia.horasTrabalhadas
            totalNormais = totalNormais + dia.horasNormais
            totalExtra60 = totalExtra60 + dia.horasExtra60
            totalExtra100 = totalExtra100 + dia.horasExtra100
            if dia.folga { qtdFolgas += 1 }
            if dia.ifood { qtdIfood += 1 }
        }

        let valorFolgas = Double(qtdFolgas) * config.valorFolga
        let valorIfood = Double(qtdIfood) * config.valorIfoodDia
        let valorExtra60 = totalExtra60.emHorasDecimais * config.valorHoraExtra60
        let valorExtra100 = totalExtra100.emHorasDecimais * config.valorHoraExtra100
        let totalGeral = valorExtra60 + valorExtra100 + valorFolgas

        return PeriodoResumo(
            referencia: referencia,
            inicio: inicio,
            fim: fim,
            dias: dias,
            totalTrabalhadas: totalTrabalhadas,
            totalNormais: totalNormais,
            totalExtra60: totalExtra60,
            totalExtra100: totalExtra100,
            quantidadeFolgas: qtdFolgas,
            quantidadeIfood: qtdIfood,
            valorFolgas: valorFolgas,
            valorIfood: valorIfood,
            valorExtra60: valorExtra60,
            valorExtra100: valorExtra100,
            totalGeralExtras: totalGeral
        )
    }
}
