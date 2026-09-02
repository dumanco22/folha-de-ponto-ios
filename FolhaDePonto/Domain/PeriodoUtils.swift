import Foundation

/// Regras de período da folha de ponto: começa no dia `diaInicio` (padrão 24) de um mês
/// e fecha no dia (diaInicio - 1) (padrão 23) do mês seguinte — exatamente como na planilha
/// original ("Início do período (dia 24)" ... "(fechamento dia 23)").
enum PeriodoUtils {

    static func referenciaParaData(_ data: DataSimples, diaInicio: Int) -> MesReferencia {
        if data.dia >= diaInicio {
            return MesReferencia(ano: data.ano, mes: data.mes)
        } else {
            return MesReferencia(ano: data.ano, mes: data.mes).adicionandoMeses(-1)
        }
    }

    static func limites(_ referencia: MesReferencia, diaInicio: Int) -> (inicio: DataSimples, fim: DataSimples) {
        let diaInicioValido = min(diaInicio, DataSimples.diasNoMes(ano: referencia.ano, mes: referencia.mes))
        let inicio = DataSimples(ano: referencia.ano, mes: referencia.mes, dia: diaInicioValido)

        let mesSeguinte = referencia.adicionandoMeses(1)
        let diaFimDesejado = max(diaInicio - 1, 1)
        let diaFimValido = min(diaFimDesejado, DataSimples.diasNoMes(ano: mesSeguinte.ano, mes: mesSeguinte.mes))
        let fim = DataSimples(ano: mesSeguinte.ano, mes: mesSeguinte.mes, dia: diaFimValido)

        return (inicio, fim)
    }

    static func diasDoPeriodo(_ referencia: MesReferencia, diaInicio: Int) -> [DataSimples] {
        let (inicio, fim) = limites(referencia, diaInicio: diaInicio)
        var dias: [DataSimples] = []
        var atual = inicio
        while atual <= fim {
            dias.append(atual)
            atual = atual.adicionandoDias(1)
        }
        return dias
    }
}
