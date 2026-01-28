import Foundation
import Combine

final class ScoreModel: ObservableObject {
    @Published var playerAName: String = "Player A" {
        didSet { persist() }
    }
    @Published var playerBName: String = "Player B" {
        didSet { persist() }
    }
    @Published var pointA: Int = 0 {
        didSet { persist() }
    }
    @Published var pointB: Int = 0 {
        didSet { persist() }
    }
    @Published var gamesA: Int = 0 {
        didSet { persist() }
    }
    @Published var gamesB: Int = 0 {
        didSet { persist() }
    }
    @Published var setsA: Int = 0 {
        didSet { persist() }
    }
    @Published var setsB: Int = 0 {
        didSet { persist() }
    }
    @Published var server: Player = .a {
        didSet { persist() }
    }
    @Published var matchOver: Bool = false {
        didSet { persist() }
    }
    @Published var history: [Snapshot] = [] {
        didSet { persist() }
    }

    private let maxSetsToWin = 6
    private let gamesToWinSet = 6
    private let storageKey = "tennisScoreState"

    init() {
        restore()
    }

    struct Snapshot: Codable, Equatable {
        var pointA: Int
        var pointB: Int
        var gamesA: Int
        var gamesB: Int
        var setsA: Int
        var setsB: Int
        var server: Player
        var matchOver: Bool
    }

    func point(to player: Player) {
        guard !matchOver else { return }
        pushHistory()
        switch player {
        case .a:
            pointA += 1
        case .b:
            pointB += 1
        }
        resolvePoint()
    }

    func undo() {
        guard let last = history.popLast() else { return }
        pointA = last.pointA
        pointB = last.pointB
        gamesA = last.gamesA
        gamesB = last.gamesB
        setsA = last.setsA
        setsB = last.setsB
        server = last.server
        matchOver = last.matchOver
    }

    func reset() {
        pointA = 0
        pointB = 0
        gamesA = 0
        gamesB = 0
        setsA = 0
        setsB = 0
        server = .a
        matchOver = false
        history = []
    }

    enum Player: String, Codable {
        case a
        case b
    }

    func setServer(_ player: Player) {
        server = player
    }

    func toggleServer() {
        server = server == .a ? .b : .a
    }

    var pointLabelA: String {
        displayPoint(for: pointA, opponentPoint: pointB)
    }

    var pointLabelB: String {
        displayPoint(for: pointB, opponentPoint: pointA)
    }

    private func displayPoint(for point: Int, opponentPoint: Int) -> String {
        if point >= 3 && opponentPoint >= 3 {
            if point == opponentPoint {
                return "40"
            }
            return point > opponentPoint ? "AD" : "40"
        }
        switch point {
        case 0: return "0"
        case 1: return "15"
        case 2: return "30"
        default: return "40"
        }
    }

    private func resolvePoint() {
        if pointA >= 4 || pointB >= 4 {
            let diff = pointA - pointB
            if diff >= 2 {
                winGame(player: .a)
            } else if diff <= -2 {
                winGame(player: .b)
            }
        }
    }

    private func winGame(player: Player) {
        pointA = 0
        pointB = 0
        switch player {
        case .a:
            gamesA += 1
        case .b:
            gamesB += 1
        }
        toggleServer()
        resolveGame()
    }

    private func resolveGame() {
        if gamesA >= gamesToWinSet || gamesB >= gamesToWinSet {
            let diff = gamesA - gamesB
            if diff >= 2 {
                winSet(player: .a)
            } else if diff <= -2 {
                winSet(player: .b)
            }
        }
    }

    private func winSet(player: Player) {
        gamesA = 0
        gamesB = 0
        switch player {
        case .a:
            setsA += 1
        case .b:
            setsB += 1
        }
        resolveMatch()
    }

    private func resolveMatch() {
        if setsA >= maxSetsToWin || setsB >= maxSetsToWin {
            startNewMatchCycle()
        }
    }

    private func startNewMatchCycle() {
        pointA = 0
        pointB = 0
        gamesA = 0
        gamesB = 0
        setsA = 0
        setsB = 0
        server = .a
        matchOver = false
        history = []
    }

    private func pushHistory() {
        let snapshot = Snapshot(
            pointA: pointA,
            pointB: pointB,
            gamesA: gamesA,
            gamesB: gamesB,
            setsA: setsA,
            setsB: setsB,
            server: server,
            matchOver: matchOver
        )
        history.append(snapshot)
        if history.count > 25 {
            history.removeFirst()
        }
    }

    private func persist() {
        let state = PersistedState(
            playerAName: playerAName,
            playerBName: playerBName,
            pointA: pointA,
            pointB: pointB,
            gamesA: gamesA,
            gamesB: gamesB,
            setsA: setsA,
            setsB: setsB,
            server: server,
            matchOver: matchOver,
            history: history
        )
        let data = try? JSONEncoder().encode(state)
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func restore() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data) else {
            return
        }
        playerAName = state.playerAName
        playerBName = state.playerBName
        pointA = state.pointA
        pointB = state.pointB
        gamesA = state.gamesA
        gamesB = state.gamesB
        setsA = state.setsA
        setsB = state.setsB
        server = state.server
        matchOver = state.matchOver
        history = state.history
    }

    private struct PersistedState: Codable {
        var playerAName: String
        var playerBName: String
        var pointA: Int
        var pointB: Int
        var gamesA: Int
        var gamesB: Int
        var setsA: Int
        var setsB: Int
        var server: Player
        var matchOver: Bool
        var history: [Snapshot]
    }
}
