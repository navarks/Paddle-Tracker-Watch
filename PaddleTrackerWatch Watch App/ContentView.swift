import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: ScoreModel
    @State private var showingResetConfirm = false
    @State private var crownValue: Double = 0
    @State private var crownSelection: Int = 0
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 6) {
                scoreRow
                gamesRow
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
            .allowsHitTesting(!showSettings)

            if showSettings {
                settingsOverlay
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.height > 20 {
                        showSettings = true
                    }
                }
        )
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: showSettings)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Undo") {
                    model.undo()
                }
                .disabled(model.history.isEmpty)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
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

    private var scoreRow: some View {
        HStack {
            Button {
                model.point(to: .a)
            } label: {
                scoreChip(label: model.pointLabelA, highlighted: crownSelection == 0, isServer: model.server == .a)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            Spacer()
            Button {
                model.point(to: .b)
            } label: {
                scoreChip(label: model.pointLabelB, highlighted: crownSelection == 1, isServer: model.server == .b)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
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
    }

    private var gamesRow: some View {
        Text("GAMES \(model.gamesA)-\(model.gamesB)")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .tracking(0.8)
            .frame(maxWidth: .infinity)
    }

    private var settingsOverlay: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    showSettings = false
                }

            VStack(spacing: 8) {
                HStack {
                    Text("Settings")
                        .font(.headline)
                    Spacer()
                    Button {
                        showSettings = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                }

                settingsRow(title: "Match length", value: "First to 6")
                settingsRow(title: "Serve", value: "Auto")
                settingsRow(title: "Names", value: "Edit")
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.top, 6)
            .padding(.horizontal, 6)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        if value.translation.height < -20 || value.translation.height > 60 {
                            showSettings = false
                        }
                    }
            )
        }
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

    private func settingsRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption2)
        }
    }

    
}

#Preview {
    ContentView()
        .environmentObject(ScoreModel())
}
