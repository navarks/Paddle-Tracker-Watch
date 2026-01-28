import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: ScoreModel
    @State private var showingResetConfirm = false
    @State private var crownValue: Double = 0
    @State private var crownSelection: Int = 0

    var body: some View {
        VStack(spacing: 10) {
            header
            scoreRow
            gameSetRow
            actions
        }
        .padding(.vertical, 6)
        .focusable(true)
        .digitalCrownRotation(
            $crownValue,
            from: 0,
            through: 1,
            by: 1,
            sensitivity: .low,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crownValue) { _, newValue in
            crownSelection = newValue > 0.5 ? 1 : 0
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Undo") {
                    model.undo()
                }
                .disabled(model.history.isEmpty)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reset") {
                    showingResetConfirm = true
                }
            }
        }
        .confirmationDialog(
            "Reset match?",
            isPresented: $showingResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                model.reset()
            }
        }
    }

    private var header: some View {
        HStack {
            Text(model.playerAName)
                .font(.caption)
                .foregroundStyle(crownSelection == 0 ? .primary : .secondary)
            Spacer()
            Text(model.playerBName)
                .font(.caption)
                .foregroundStyle(crownSelection == 1 ? .primary : .secondary)
        }
        .lineLimit(1)
    }

    private var scoreRow: some View {
        HStack {
            scoreChip(label: model.pointLabelA, highlighted: crownSelection == 0)
            Spacer()
            scoreChip(label: model.pointLabelB, highlighted: crownSelection == 1)
        }
    }

    private var gameSetRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Games")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(model.gamesA)-\(model.gamesB)")
                    .font(.headline)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Sets")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(model.setsA)-\(model.setsB)")
                    .font(.headline)
            }
        }
    }

    private var actions: some View {
        HStack(spacing: 8) {
            Button("Point A") {
                model.point(to: .a)
            }
            .buttonStyle(.bordered)
            .tint(crownSelection == 0 ? .blue : .gray)

            Button("Point B") {
                model.point(to: .b)
            }
            .buttonStyle(.bordered)
            .tint(crownSelection == 1 ? .blue : .gray)
        }
        .font(.footnote)
    }

    private func scoreChip(label: String, highlighted: Bool) -> some View {
        Text(label)
            .font(.title3)
            .frame(width: 48, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(highlighted ? Color.blue.opacity(0.2) : Color.gray.opacity(0.15))
            )
    }
}

#Preview {
    ContentView()
        .environmentObject(ScoreModel())
}
