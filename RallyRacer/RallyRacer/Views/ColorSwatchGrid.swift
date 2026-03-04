import SwiftUI

struct ColorSwatchGrid: View {
    let selected: String
    let onSelect: (String) -> Void

    private let columns = Array(repeating: GridItem(.fixed(32), spacing: 6), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(ColorPalette.colors, id: \.self) { hex in
                SwatchCircle(hex: hex, isSelected: hex == selected)
                    .onTapGesture { onSelect(hex) }
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
}

private struct SwatchCircle: View {
    let hex: String
    let isSelected: Bool

    var body: some View {
        Circle()
            .fill(Color(hex: hex))
            .frame(width: 28, height: 28)
            .overlay(selectionOverlay)
    }

    @ViewBuilder
    private var selectionOverlay: some View {
        if isSelected {
            Circle().stroke(Color.white, lineWidth: 2)
        }
    }
}
