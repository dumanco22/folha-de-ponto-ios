import SwiftUI

struct CampoHorario: View {
    let rotulo: String
    let valor: Horario?
    let aoSelecionar: (Horario) -> Void
    var aoLimpar: (() -> Void)? = nil

    @State private var mostrarSeletor = false
    @State private var dataTemporaria = Date()

    var body: some View {
        Button {
            dataTemporaria = Self.dataPara(valor)
            mostrarSeletor = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(rotulo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(valor?.textoFormatado ?? "--:--")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.primary)
                }
                Spacer()
                if valor != nil, let aoLimpar {
                    Button(action: aoLimpar) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.secondarySystemBackground)))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $mostrarSeletor) {
            NavigationStack {
                DatePicker(rotulo, selection: $dataTemporaria, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    .navigationTitle(rotulo)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") { mostrarSeletor = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("OK") {
                                aoSelecionar(Self.horarioPara(dataTemporaria))
                                mostrarSeletor = false
                            }
                        }
                    }
            }
            .presentationDetents([.height(320)])
        }
    }

    private static func dataPara(_ horario: Horario?) -> Date {
        let agora = Calendar.current.dateComponents([.hour, .minute], from: Date())
        var componentes = DateComponents()
        componentes.hour = horario?.hora ?? agora.hour
        componentes.minute = horario?.minuto ?? agora.minute
        return Calendar.current.date(from: componentes) ?? Date()
    }

    private static func horarioPara(_ data: Date) -> Horario {
        let componentes = Calendar.current.dateComponents([.hour, .minute], from: data)
        return Horario(hora: componentes.hour ?? 0, minuto: componentes.minute ?? 0)
    }
}
