import SwiftUI
import SwiftData

struct InicioView: View {
    @EnvironmentObject private var configuracaoStore: ConfiguracaoStore
    @Environment(\.modelContext) private var contexto
    @StateObject private var viewModel = InicioViewModel()

    @State private var arquivoParaCompartilhar: ArquivoParaCompartilhar?
    @State private var mostrarErroExportacao = false

    var body: some View {
        NavigationStack {
            Group {
                if let resumo = viewModel.resumo {
                    conteudo(resumo: resumo)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Folha de Ponto")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ConfiguracoesView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .task {
                viewModel.carregar(contexto: contexto, config: configuracaoStore.config)
            }
            .onChange(of: configuracaoStore.config) { _, novaConfig in
                viewModel.carregar(contexto: contexto, config: novaConfig)
            }
            .sheet(item: $arquivoParaCompartilhar) { item in
                ActivityView(itens: [item.url])
            }
            .alert("Não foi possível gerar o PDF", isPresented: $mostrarErroExportacao) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    @ViewBuilder
    private func conteudo(resumo: PeriodoResumo) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                seletorPeriodo(resumo: resumo)
                cartaoBaterPonto
                resumoDoPeriodo(resumo: resumo)
                listaDeDias(resumo: resumo)
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .safeAreaInset(edge: .bottom) {
            botaoExportarPdf(resumo: resumo)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
    }

    private func seletorPeriodo(resumo: PeriodoResumo) -> some View {
        VStack(spacing: 6) {
            HStack {
                Button {
                    viewModel.periodoAnterior(contexto: contexto, config: configuracaoStore.config)
                } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                VStack(spacing: 2) {
                    Text(resumo.tituloPeriodo)
                        .font(.title2.bold())
                    Text("\(resumo.inicio.formatadaCompleta) a \(resumo.fim.formatadaCompleta)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    viewModel.periodoSeguinte(contexto: contexto, config: configuracaoStore.config)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            if !viewModel.ehPeriodoAtual {
                Button("Ir para o período atual") {
                    viewModel.voltarAoPeriodoAtual(contexto: contexto, config: configuracaoStore.config)
                }
                .font(.footnote)
            }
        }
    }

    private var cartaoBaterPonto: some View {
        let (rotulo, habilitado): (String, Bool) = {
            switch viewModel.proximaAcao {
            case .entrada: return ("Bater Entrada", true)
            case .saidaAlmoco: return ("Bater Saída Almoço", true)
            case .retornoAlmoco: return ("Bater Retorno Almoço", true)
            case .saida: return ("Bater Saída", true)
            case nil: return ("Ponto de hoje completo", false)
            }
        }()

        return Button {
            viewModel.baterPonto(contexto: contexto, config: configuracaoStore.config)
        } label: {
            HStack {
                Image(systemName: "clock.badge.checkmark")
                Text(rotulo).font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!habilitado)
    }

    private func resumoDoPeriodo(resumo: PeriodoResumo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Resumo do período").font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    CartaoResumo(titulo: "Trabalhadas", valor: resumo.totalTrabalhadas.textoFormatado)
                    CartaoResumo(
                        titulo: "Extra 60%", valor: resumo.totalExtra60.textoFormatado,
                        subtitulo: Formatadores.moeda(resumo.valorExtra60), corDestaque: .orange
                    )
                    CartaoResumo(
                        titulo: "Extra 100%", valor: resumo.totalExtra100.textoFormatado,
                        subtitulo: Formatadores.moeda(resumo.valorExtra100), corDestaque: .red
                    )
                    CartaoResumo(
                        titulo: "Folgas", valor: "\(resumo.quantidadeFolgas)",
                        subtitulo: Formatadores.moeda(resumo.valorFolgas)
                    )
                    CartaoResumo(
                        titulo: "IFOOD", valor: "\(resumo.quantidadeIfood)",
                        subtitulo: Formatadores.moeda(resumo.valorIfood)
                    )
                }
            }

            CartaoResumo(
                titulo: "Total geral de extras (60% + 100% + folgas)",
                valor: Formatadores.moeda(resumo.totalGeralExtras),
                corDestaque: .accentColor
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func listaDeDias(resumo: PeriodoResumo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dias do período").font(.headline)
            LazyVStack(spacing: 6) {
                ForEach(resumo.dias) { dia in
                    NavigationLink(destination: DiaDetalheView(dataIso: dia.id)) {
                        LinhaDia(dia: dia, ehHoje: dia.data == DataSimples.hoje())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func botaoExportarPdf(resumo: PeriodoResumo) -> some View {
        Button {
            exportarPdf(resumo: resumo)
        } label: {
            HStack {
                Image(systemName: "doc.richtext")
                Text("Exportar PDF")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func exportarPdf(resumo: PeriodoResumo) {
        if let url = PdfExporter.gerar(resumo: resumo, config: configuracaoStore.config) {
            arquivoParaCompartilhar = ArquivoParaCompartilhar(url: url)
        } else {
            mostrarErroExportacao = true
        }
    }
}

struct ArquivoParaCompartilhar: Identifiable {
    let id = UUID()
    let url: URL
}

#Preview {
    InicioView()
        .environmentObject(ConfiguracaoStore())
        .modelContainer(for: DiaPonto.self, inMemory: true)
}
