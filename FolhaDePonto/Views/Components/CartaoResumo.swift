import SwiftUI

struct CartaoResumo: View {
    let titulo: String
    let valor: String
    var subtitulo: String? = nil
    var corDestaque: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titulo)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(valor)
                .font(.title2.bold())
                .foregroundStyle(corDestaque)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if let subtitulo {
                Text(subtitulo)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(minWidth: 140, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.secondarySystemBackground)))
    }
}
