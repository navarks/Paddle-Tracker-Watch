import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: ScoreModel
    @State private var showingResetConfirm = false
    @State private var crownValue: Double = 0
    @State private var crownSelection: Int = 0

    var body: some View {
        VStack(spacing: 6) {
            header
            scoreRow
            gameSetRow
            actions
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
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
        HStack(alignment: .center, spacing: 8) {
            playerName(label: model.playerAName, isSelected: crownSelection == 0, isServer: model.server == .a)
            Spacer(minLength: 6)
            Text("VS")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer(minLength: 6)
            playerName(label: model.playerBName, isSelected: crownSelection == 1, isServer: model.server == .b)
        }
        .lineLimit(1)
    }

    private var scoreRow: some View {
        HStack {
            scoreChip(label: model.pointLabelA, highlighted: crownSelection == 0, isServer: model.server == .a)
            Spacer()
            scoreChip(label: model.pointLabelB, highlighted: crownSelection == 1, isServer: model.server == .b)
        }
    }

    private var gameSetRow: some View {
        HStack {
            metricBlock(title: "Games", value: "\(model.gamesA)-\(model.gamesB)")
            Spacer()
            metricBlock(title: "Sets", value: "\(model.setsA)-\(model.setsB)")
        }
    }

    private var actions: some View {
        HStack(spacing: 8) {
            actionButton(title: "+ A", player: .a, isSelected: crownSelection == 0)
            actionButton(title: "+ B", player: .b, isSelected: crownSelection == 1)
        }
        .font(.footnote)
    }

    private func scoreChip(label: String, highlighted: Bool, isServer: Bool) -> some View {
        Text(label)
            .font(.system(size: 19, weight: .semibold))
            .frame(width: 52, height: 34)
            .background(scoreChipBackground(highlighted: highlighted, isServer: isServer))
            .shadow(color: isServer ? Color.accentColor.opacity(0.12) : Color.clear, radius: 4, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isServer ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1)
            )
    }

    private func scoreChipBackground(highlighted: Bool, isServer: Bool) -> some ShapeStyle {
        let base = highlighted ? Color.accentColor.opacity(0.22) : Color.gray.opacity(0.14)
        return AnyShapeStyle(base)
    }

    private func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(.secondary)
                .tracking(0.6)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
        }
    }

    private func actionButton(title: String, player: ScoreModel.Player, isSelected: Bool) -> some View {
        Button(title) {
            model.point(to: player)
        }
        .buttonStyle(.borderedProminent)
        .tint(isSelected ? .accentColor : .gray)
    }

    private func playerName(label: String, isSelected: Bool, isServer: Bool) -> some View {
        HStack(spacing: 4) {
            if isServer {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 6, height: 6)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ScoreModel())
}
