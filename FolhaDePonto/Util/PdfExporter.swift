import UIKit

/// Gera um PDF do período no mesmo espírito da planilha original: uma linha por dia
/// com os horários e as horas calculadas, seguida do total do período e dos valores.
enum PdfExporter {
    private static let larguraPagina: CGFloat = 842 // A4 paisagem, em pontos (72dpi)
    private static let alturaPagina: CGFloat = 595
    private static let margem: CGFloat = 28

    private static let colunas: [(titulo: String, peso: CGFloat)] = [
        ("Data", 0.07), ("Dia", 0.09), ("Ent.Prev", 0.07), ("Saí.Prev", 0.07),
        ("Entrada", 0.08), ("S.Almoço", 0.08), ("R.Almoço", 0.08), ("Saída", 0.08),
        ("Trabalh.", 0.08), ("Normais", 0.08), ("Extra60%", 0.08), ("Extra100%", 0.08),
        ("IFOOD", 0.03), ("Folga", 0.03)
    ]

    static func gerar(resumo: PeriodoResumo, config: ConfiguracaoData) -> URL? {
        let formato = UIGraphicsPDFRendererFormat()
        let renderizador = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: larguraPagina, height: alturaPagina),
            format: formato
        )

        let nomeArquivo = "folha_de_ponto_\(resumo.referencia.chave).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(nomeArquivo)

        do {
            try renderizador.writePDF(to: url) { contexto in
                desenhar(contexto: contexto, resumo: resumo, config: config)
            }
            return url
        } catch {
            return nil
        }
    }

    private static func desenhar(contexto: UIGraphicsPDFRendererContext, resumo: PeriodoResumo, config: ConfiguracaoData) {
        let larguraUtil = larguraPagina - 2 * margem

        let atrTitulo: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 16)]
        let atrSubtitulo: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.darkGray]
        let atrCabecalho: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 8), .foregroundColor: UIColor.white]
        let atrCelula: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 8), .foregroundColor: UIColor.black]
        let atrTotal: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 9), .foregroundColor: UIColor.black]

        func xDaColuna(_ indice: Int) -> CGFloat {
            var x = margem
            for i in 0..<indice { x += larguraUtil * colunas[i].peso }
            return x
        }

        var y: CGFloat = margem

        func desenharCabecalhoTabela() {
            let altura: CGFloat = 18
            UIColor(red: 46 / 255, green: 92 / 255, blue: 138 / 255, alpha: 1).setFill()
            UIBezierPath(rect: CGRect(x: margem, y: y, width: larguraUtil, height: altura)).fill()
            for (i, coluna) in colunas.enumerated() {
                (coluna.titulo as NSString).draw(at: CGPoint(x: xDaColuna(i) + 3, y: y + 4), withAttributes: atrCabecalho)
            }
            y += altura
        }

        contexto.beginPage()

        (("FOLHA DE PONTO — " + resumo.tituloPeriodo) as NSString).draw(at: CGPoint(x: margem, y: y), withAttributes: atrTitulo)
        y += 22
        (("\(config.nomeFuncionario)  •  \(config.cargoMatricula)  •  \(config.empresa)") as NSString)
            .draw(at: CGPoint(x: margem, y: y), withAttributes: atrSubtitulo)
        y += 14
        (("Período: \(resumo.inicio.formatadaCompleta) a \(resumo.fim.formatadaCompleta)") as NSString)
            .draw(at: CGPoint(x: margem, y: y), withAttributes: atrSubtitulo)
        y += 24

        desenharCabecalhoTabela()

        let alturaLinha: CGFloat = 15
        for dia in resumo.dias {
            if y > alturaPagina - 90 {
                contexto.beginPage()
                y = margem
                desenharCabecalhoTabela()
            }

            if dia.folga {
                UIColor(red: 235 / 255, green: 245 / 255, blue: 235 / 255, alpha: 1).setFill()
                UIBezierPath(rect: CGRect(x: margem, y: y, width: larguraUtil, height: alturaLinha)).fill()
            } else if dia.fimDeSemana {
                UIColor(red: 255 / 255, green: 244 / 255, blue: 230 / 255, alpha: 1).setFill()
                UIBezierPath(rect: CGRect(x: margem, y: y, width: larguraUtil, height: alturaLinha)).fill()
            }

            let valores: [String] = [
                dia.data.formatadaCurta,
                dia.data.nomeDiaDaSemana,
                dia.entradaPrevista.textoFormatado,
                dia.saidaPrevista.textoFormatado,
                dia.entradaReal?.textoFormatado ?? "--:--",
                dia.saidaAlmoco?.textoFormatado ?? "--:--",
                dia.retornoAlmoco?.textoFormatado ?? "--:--",
                dia.saidaReal?.textoFormatado ?? "--:--",
                dia.horasTrabalhadas.minutos > 0 ? dia.horasTrabalhadas.textoFormatado : "-",
                dia.horasNormais.minutos > 0 ? dia.horasNormais.textoFormatado : "-",
                dia.horasExtra60.minutos > 0 ? dia.horasExtra60.textoFormatado : "-",
                dia.horasExtra100.minutos > 0 ? dia.horasExtra100.textoFormatado : "-",
                dia.ifood ? "X" : "",
                dia.folga ? "X" : ""
            ]
            for (i, texto) in valores.enumerated() {
                (texto as NSString).draw(at: CGPoint(x: xDaColuna(i) + 3, y: y + 3), withAttributes: atrCelula)
            }

            let linha = UIBezierPath()
            linha.move(to: CGPoint(x: margem, y: y + alturaLinha))
            linha.addLine(to: CGPoint(x: margem + larguraUtil, y: y + alturaLinha))
            linha.lineWidth = 0.5
            UIColor(white: 0.85, alpha: 1).setStroke()
            linha.stroke()

            y += alturaLinha
        }

        y += 10
        if y > alturaPagina - 110 {
            contexto.beginPage()
            y = margem
        }

        let linhaTotal = UIBezierPath()
        linhaTotal.move(to: CGPoint(x: margem, y: y))
        linhaTotal.addLine(to: CGPoint(x: margem + larguraUtil, y: y))
        linhaTotal.lineWidth = 1
        UIColor.black.setStroke()
        linhaTotal.stroke()
        y += 16

        (("TOTAL DO PERÍODO:   Trabalhadas \(resumo.totalTrabalhadas.textoFormatado)   •   " +
          "Normais \(resumo.totalNormais.textoFormatado)   •   " +
          "Extra 60% \(resumo.totalExtra60.textoFormatado)   •   " +
          "Extra 100% \(resumo.totalExtra100.textoFormatado)") as NSString)
            .draw(at: CGPoint(x: margem, y: y), withAttributes: atrTotal)
        y += 18

        (("Folgas: \(resumo.quantidadeFolgas) (\(Formatadores.moeda(resumo.valorFolgas)))   •   " +
          "IFOOD: \(resumo.quantidadeIfood) (\(Formatadores.moeda(resumo.valorIfood)))") as NSString)
            .draw(at: CGPoint(x: margem, y: y), withAttributes: atrCelula)
        y += 18

        (("Valor hora extra 60%: \(Formatadores.moeda(config.valorHoraExtra60))   •   " +
          "Valor hora extra 100%: \(Formatadores.moeda(config.valorHoraExtra100))") as NSString)
            .draw(at: CGPoint(x: margem, y: y), withAttributes: atrCelula)
        y += 18

        (("Extra 60% a receber: \(Formatadores.moeda(resumo.valorExtra60))   •   " +
          "Extra 100% a receber: \(Formatadores.moeda(resumo.valorExtra100))") as NSString)
            .draw(at: CGPoint(x: margem, y: y), withAttributes: atrCelula)
        y += 24

        (("TOTAL GERAL DE EXTRAS: \(Formatadores.moeda(resumo.totalGeralExtras))") as NSString)
            .draw(at: CGPoint(x: margem, y: y), withAttributes: atrTitulo)
    }
}
