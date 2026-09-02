import SwiftUI

struct ConfiguracoesView: View {
    @EnvironmentObject private var configuracaoStore: ConfiguracaoStore
    @State private var rascunho: ConfiguracaoData = ConfiguracaoData()
    @State private var carregado = false
    @State private var mostrarConfirmacao = false

    var body: some View {
        Form {
            Section("Dados do funcionário") {
                TextField("Nome", text: $rascunho.nomeFuncionario)
                TextField("Cargo / Matrícula", text: $rascunho.cargoMatricula)
                TextField("Empresa", text: $rascunho.empresa)
            }

            Section {
                Stepper(value: $rascunho.diaInicioPeriodo, in: 1...28) {
                    HStack {
                        Text("Dia de início")
                        Spacer()
                        Text("\(rascunho.diaInicioPeriodo)").foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Período de fechamento")
            } footer: {
                Text("O período começa no dia \(rascunho.diaInicioPeriodo) e fecha no dia \(max(rascunho.diaInicioPeriodo - 1, 1)) do mês seguinte.")
            }

            Section("Segunda a quinta") {
                CampoHorarioTexto(rotulo: "Entrada", valor: $rascunho.segQuiEntrada)
                CampoHorarioTexto(rotulo: "Saída", valor: $rascunho.segQuiSaida)
            }

            Section("Sexta-feira") {
                CampoHorarioTexto(rotulo: "Entrada", valor: $rascunho.sextaEntrada)
                CampoHorarioTexto(rotulo: "Saída", valor: $rascunho.sextaSaida)
            }

            Section("Almoço (dias de semana)") {
                CampoHorarioTexto(rotulo: "Saída almoço", valor: $rascunho.almocoSaida)
                CampoHorarioTexto(rotulo: "Retorno almoço", valor: $rascunho.almocoRetorno)
            }

            Section("Sábado (extra 100%)") {
                CampoHorarioTexto(rotulo: "Entrada", valor: $rascunho.sabadoEntrada)
                CampoHorarioTexto(rotulo: "Saída", valor: $rascunho.sabadoSaida)
            }

            Section("Domingo (extra 100%)") {
                CampoHorarioTexto(rotulo: "Entrada", valor: $rascunho.domingoEntrada)
                CampoHorarioTexto(rotulo: "Saída", valor: $rascunho.domingoSaida)
            }

            Section {
                CampoValor(rotulo: "Valor da hora normal", valor: $rascunho.valorHoraNormal)
                HStack {
                    Text("Hora extra 60%").foregroundStyle(.secondary)
                    Spacer()
                    Text(Formatadores.moeda(rascunho.valorHoraExtra60))
                }
                .font(.footnote)
                HStack {
                    Text("Hora extra 100%").foregroundStyle(.secondary)
                    Spacer()
                    Text(Formatadores.moeda(rascunho.valorHoraExtra100))
                }
                .font(.footnote)
                CampoValor(rotulo: "Valor da folga", valor: $rascunho.valorFolga)
                CampoValor(rotulo: "Valor do IFOOD por dia", valor: $rascunho.valorIfoodDia)
            } header: {
                Text("Valores (R$)")
            }

            Section {
                Button {
                    configuracaoStore.salvar(rascunho)
                    mostrarConfirmacao = true
                } label: {
                    Text("Salvar configurações")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .listRowInsets(EdgeInsets())
                .padding()
            }
        }
        .navigationTitle("Configurações")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !carregado {
                rascunho = configuracaoStore.config
                carregado = true
            }
        }
        .alert("Configurações salvas", isPresented: $mostrarConfirmacao) {
            Button("OK", role: .cancel) {}
        }
    }
}

/// Campo de horário simples em formato "HH:mm" usado na tela de Configurações
/// (aqui um texto editável de forma direta é suficiente, já que representa um padrão,
/// não um horário batido).
private struct CampoHorarioTexto: View {
    let rotulo: String
    @Binding var valor: String

    var body: some View {
        DatePicker(rotulo, selection: Binding(
            get: { Self.dataPara(valor) },
            set: { valor = Self.textoPara($0) }
        ), displayedComponents: .hourAndMinute)
    }

    private static func dataPara(_ texto: String) -> Date {
        guard let horario = Horario(texto: texto) else { return Date() }
        var componentes = DateComponents()
        componentes.hour = horario.hora
        componentes.minute = horario.minuto
        return Calendar.current.date(from: componentes) ?? Date()
    }

    private static func textoPara(_ data: Date) -> String {
        let componentes = Calendar.current.dateComponents([.hour, .minute], from: data)
        return Horario(hora: componentes.hour ?? 0, minuto: componentes.minute ?? 0).textoFormatado
    }
}

private struct CampoValor: View {
    let rotulo: String
    @Binding var valor: Double

    var body: some View {
        HStack {
            Text(rotulo)
            Spacer()
            TextField("0,00", value: $valor, format: .number.precision(.fractionLength(2)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 90)
        }
    }
}

#Preview {
    NavigationStack {
        ConfiguracoesView()
            .environmentObject(ConfiguracaoStore())
    }
}
