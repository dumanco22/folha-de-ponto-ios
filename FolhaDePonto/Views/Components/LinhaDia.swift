import SwiftUI

struct LinhaDia: View {
    let dia: DiaCalculado
    let ehHoje: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(dia.data.formatadaCurta)
                    .font(.headline)
                Text(dia.data.nomeDiaAbreviado)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 52, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                if dia.folga {
                    Text("Folga")
                        .font(.subheadline)
                } else {
                    Text("\(dia.entradaReal?.textoFormatado ?? "--:--")  —  \(dia.saidaReal?.textoFormatado ?? "--:--")")
                        .font(.subheadline)
                        .foregroundStyle(dia.registroCompleto ? .primary : .secondary)
                }
                HStack(spacing: 4) {
                    if dia.ifood {
                        Image(systemName: "fork.knife")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                    if dia.fimDeSemana {
                        Text("extra 100%")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                if dia.horasTrabalhadas.minutos > 0 {
                    Text(dia.horasTrabalhadas.textoFormatado)
                        .font(.subheadline.weight(.semibold))
                }
                if dia.horasExtra60.minutos > 0 {
                    SelinhoExtra(texto: "+\(dia.horasExtra60.textoFormatado) (60%)", cor: .orange)
                }
                if dia.horasExtra100.minutos > 0 {
                    SelinhoExtra(texto: "+\(dia.horasExtra100.textoFormatado) (100%)", cor: .red)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ehHoje ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground))
        )
        .contentShape(Rectangle())
    }
}

private struct SelinhoExtra: View {
    let texto: String
    let cor: Color

    var body: some View {
        Text(texto)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(cor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(cor.opacity(0.12)))
    }
}
