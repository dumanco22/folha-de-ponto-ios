import SwiftUI
import SwiftData

struct DiaDetalheView: View {
    let dataIso: String

    @EnvironmentObject private var configuracaoStore: ConfiguracaoStore
    @Environment(\.modelContext) private var contexto
    @StateObject private var viewModel = DiaDetalheViewModel()
    @State private var observacao: String = ""

    var body: some View {
        Group {
            if let dia = viewModel.dia {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        cartaoPrevisto(dia: dia)
                        registroDePonto(dia: dia)
                        extrasDoDia(dia: dia)
                        campoObservacao
                        cartaoCalculo(dia: dia)
                    }
                    .padding(16)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(tituloTela)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.carregar(dataIso: dataIso, contexto: contexto, config: configuracaoStore.config)
            observacao = viewModel.dia?.observacao ?? ""
        }
    }

    private var tituloTela: String {
        guard let data = DataSimples(iso: dataIso) else { return "Dia" }
        return "\(data.nomeDiaDaSemana), \(data.formatadaCompleta)"
    }

    private func cartaoPrevisto(dia: DiaCalculado) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Horário previsto")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(dia.entradaPrevista.textoFormatado) às \(dia.saidaPrevista.textoFormatado)")
                .font(.title3.weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.secondarySystemBackground)))
    }

    private func registroDePonto(dia: DiaCalculado) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Registro de ponto").font(.headline)

            CampoHorario(
                rotulo: "Entrada",
                valor: dia.entradaReal,
                aoSelecionar: { viewModel.salvarHorario(.entrada, valor: $0, contexto: contexto) },
                aoLimpar: { viewModel.salvarHorario(.entrada, valor: nil, contexto: contexto) }
            )

            if !dia.fimDeSemana {
                HStack(spacing: 10) {
                    CampoHorario(
                        rotulo: "Saída almoço",
                        valor: dia.saidaAlmoco,
                        aoSelecionar: { viewModel.salvarHorario(.saidaAlmoco, valor: $0, contexto: contexto) },
                        aoLimpar: { viewModel.salvarHorario(.saidaAlmoco, valor: nil, contexto: contexto) }
                    )
                    CampoHorario(
                        rotulo: "Retorno almoço",
                        valor: dia.retornoAlmoco,
                        aoSelecionar: { viewModel.salvarHorario(.retornoAlmoco, valor: $0, contexto: contexto) },
                        aoLimpar: { viewModel.salvarHorario(.retornoAlmoco, valor: nil, contexto: contexto) }
                    )
                }
            }

            CampoHorario(
                rotulo: "Saída",
                valor: dia.saidaReal,
                aoSelecionar: { viewModel.salvarHorario(.saida, valor: $0, contexto: contexto) },
                aoLimpar: { viewModel.salvarHorario(.saida, valor: nil, contexto: contexto) }
            )
        }
    }

    private func extrasDoDia(dia: DiaCalculado) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Extras do dia").font(.headline)

            Toggle(isOn: Binding(
                get: { dia.folga },
                set: { viewModel.alternarFolga($0, contexto: contexto) }
            )) {
                Text("Folga (\(Formatadores.moeda(viewModel.config.valorFolga)))")
            }

            Toggle(isOn: Binding(
                get: { dia.ifood },
                set: { viewModel.alternarIfood($0, contexto: contexto) }
            )) {
                Text("IFOOD (\(Formatadores.moeda(viewModel.config.valorIfoodDia)))")
            }
        }
    }

    private var campoObservacao: some View {
        VStack(alignment: .trailing, spacing: 6) {
            TextField("Observação", text: $observacao, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
            Button("Salvar observação") {
                viewModel.salvarObservacao(observacao, contexto: contexto)
            }
            .font(.footnote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func cartaoCalculo(dia: DiaCalculado) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Cálculo do dia")
                .font(.caption)
                .foregroundStyle(.secondary)
            linhaCalculo("Horas trabalhadas", dia.horasTrabalhadas.textoFormatado)
            linhaCalculo("Horas normais", dia.horasNormais.textoFormatado)
            linhaCalculo("Extra 60%", dia.horasExtra60.textoFormatado, cor: .orange)
            linhaCalculo("Extra 100%", dia.horasExtra100.textoFormatado, cor: .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.accentColor.opacity(0.12)))
    }

    private func linhaCalculo(_ rotulo: String, _ valor: String, cor: Color = .primary) -> some View {
        HStack {
            Text(rotulo).font(.subheadline)
            Spacer()
            Text(valor).font(.subheadline.weight(.semibold)).foregroundStyle(cor)
        }
    }
}
