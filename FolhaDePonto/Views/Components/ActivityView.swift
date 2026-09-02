import SwiftUI
import UIKit

/// Ponte para o UIActivityViewController (tela de compartilhar/salvar arquivo do iOS).
struct ActivityView: UIViewControllerRepresentable {
    let itens: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: itens, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
