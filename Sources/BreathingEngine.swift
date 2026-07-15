import SwiftUI
import Combine

final class BreathingEngine: ObservableObject {

    enum Phase: Equatable {
        case inhale, exhale

        var label: String {
            switch self {
            case .inhale: return "吸气"
            case .exhale: return "呼气"
            }
        }

        var color: Color {
            switch self {
            case .inhale: return Color(red: 0.30, green: 0.60, blue: 1.00)
            case .exhale: return Color(red: 1.00, green: 0.52, blue: 0.32)
            }
        }

        var next: Phase { self == .inhale ? .exhale : .inhale }
    }

    private static let minScale: Double = 0.6
    private static let maxScale: Double = 1.3

    @Published var inhaleSeconds: Int = 4 {
        didSet {
            UserDefaults.standard.set(inhaleSeconds, forKey: "inhaleSeconds")
            if !isRunning { reset() }
        }
    }
    @Published var exhaleSeconds: Int = 4 {
        didSet {
            UserDefaults.standard.set(exhaleSeconds, forKey: "exhaleSeconds")
            if !isRunning { reset() }
        }
    }

    @Published var phase: Phase = .inhale
    @Published var progress: Double = BreathingEngine.minScale
    @Published var remainingSeconds: Int = 0
    @Published var isRunning = false

    @Published var opacity: Double = 0.85 {
        didSet { UserDefaults.standard.set(opacity, forKey: "opacity") }
    }

    @Published var isCompactMode: Bool = false {
        didSet { UserDefaults.standard.set(isCompactMode, forKey: "isCompactMode") }
    }

    private var timer: Timer?
    private var phaseStartTime: Date?

    var currentPhaseSeconds: Int {
        phase == .inhale ? inhaleSeconds : exhaleSeconds
    }

    var brightness: Double {
        guard isRunning else { return 0.7 }
        let t = (progress - Self.minScale) / (Self.maxScale - Self.minScale)
        switch phase {
        case .inhale: return 0.55 + t * 0.45
        case .exhale: return 1.0 - t * 0.45
        }
    }

    init() {
        let d = UserDefaults.standard

        let savedInhale = d.integer(forKey: "inhaleSeconds")
        inhaleSeconds = savedInhale > 0 ? savedInhale : 4

        let savedExhale = d.integer(forKey: "exhaleSeconds")
        exhaleSeconds = savedExhale > 0 ? savedExhale : 4

        let savedOpacity = d.double(forKey: "opacity")
        opacity = savedOpacity > 0 ? savedOpacity : 0.85

        isCompactMode = d.bool(forKey: "isCompactMode")
        remainingSeconds = inhaleSeconds
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        phaseStartTime = Date()
        remainingSeconds = currentPhaseSeconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func toggle() { isRunning ? pause() : start() }

    func reset() {
        pause()
        phase = .inhale
        remainingSeconds = inhaleSeconds
        progress = Self.minScale
    }

    private func tick() {
        guard let startTime = phaseStartTime else { return }
        let elapsed  = Date().timeIntervalSince(startTime)
        let total    = Double(currentPhaseSeconds)
        let fraction = min(elapsed / total, 1.0)
        remainingSeconds = max(Int(ceil(total - elapsed)), 0)
        progress = phase == .inhale
            ? Self.minScale + (Self.maxScale - Self.minScale) * fraction
            : Self.maxScale - (Self.maxScale - Self.minScale) * fraction

        guard elapsed >= total else { return }
        phase = phase.next
        phaseStartTime = Date()
        remainingSeconds = currentPhaseSeconds
    }

    deinit { timer?.invalidate() }
}
