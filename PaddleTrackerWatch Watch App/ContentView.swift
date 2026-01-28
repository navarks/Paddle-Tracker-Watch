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
            .padding(.vertical, 2)
            .padding(.horizontal, 0)
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
                    LinearGradient(
                        colors: [Color(red: 0.18, green: 0.58, blue: 0.95), Color(red: 0.07, green: 0.22, blue: 0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.ultraThinMaterial)
                        .opacity(0.35)
                    RoundedRectangle(cornerRadius: 0)
                        .fill(LinearGradient(colors: [Color.white.opacity(0.35), Color.clear], startPoint: .topLeading, endPoint: .center))
                    Text(model.pointLabelA)
                        .font(.system(size: 46, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 1)
                        .minimumScaleFactor(0.6)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.2))
                    .frame(height: 24)
                Text("\(model.gamesA)-\(model.gamesB)")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.85))
                    .tracking(1.0)
            }

            Button {
                model.point(to: .b)
            } label: {
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.20, green: 0.74, blue: 0.50), Color(red: 0.05, green: 0.38, blue: 0.24)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.ultraThinMaterial)
                        .opacity(0.35)
                    RoundedRectangle(cornerRadius: 0)
                        .fill(LinearGradient(colors: [Color.white.opacity(0.35), Color.clear], startPoint: .topLeading, endPoint: .center))
                    Text(model.pointLabelB)
                        .font(.system(size: 46, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 1)
                        .minimumScaleFactor(0.6)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
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
