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
        VStack(spacing: 0) {
            Button {
                model.point(to: .a)
            } label: {
                ZStack {
                    Color(red: 0.16, green: 0.52, blue: 0.32)
                    Text(model.pointLabelA)
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.6)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(crownSelection == 0 ? 0.5 : 0.12), lineWidth: crownSelection == 0 ? 2 : 1)
                )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.18))
                    .frame(height: 22)
                Text("\(model.gamesA)-\(model.gamesB)")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.8))
                    .tracking(0.6)
            }

            Button {
                model.point(to: .b)
            } label: {
                ZStack {
                    Color(red: 0.14, green: 0.24, blue: 0.54)
                    Text(model.pointLabelB)
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.6)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(crownSelection == 1 ? 0.5 : 0.12), lineWidth: crownSelection == 1 ? 2 : 1)
                )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
