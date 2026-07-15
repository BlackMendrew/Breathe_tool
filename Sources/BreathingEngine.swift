import SwiftUI
import Combine

final class BreathingEngine: ObservableObject {

    enum Phase: Equatable {
        case inhale, holdAfterInhale, exhale, holdAfterExhale

        var label: String {
            switch self {
            case .inhale, .holdAfterInhale:   return "吸气"
            case .exhale, .holdAfterExhale:   return "呼气"
            }
        }

        var isHolding: Bool {
            self == .holdAfterInhale || self == .holdAfterExhale
        }

        var next: Phase {
            switch self {
            case .inhale:           return .holdAfterInhale
            case .holdAfterInhale:  return .exhale
            case .exhale:           return .holdAfterExhale
            case .holdAfterExhale:  return .inhale
            }
        }
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
    @Published var holdSeconds: Double = 0 {
        didSet {
            UserDefaults.standard.set(holdSeconds, forKey: "holdSeconds")
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

    var currentPhaseSeconds: Double {
        switch phase {
        case .inhale:           return Double(inhaleSeconds)
        case .exhale:           return Double(exhaleSeconds)
        case .holdAfterInhale,
             .holdAfterExhale:  return holdSeconds
        }
    }

    let breathColor = Color(red: 0.22, green: 0.65, blue: 0.70)

    var fraction: Double {
        (progress - Self.minScale) / (Self.maxScale - Self.minScale)
    }

    var brightness: Double {
        guard isRunning else { return 0.7 }
        return 0.55 + fraction * 0.45
    }

    init() {
        let d = UserDefaults.standard

        let savedInhale = d.integer(forKey: "inhaleSeconds")
        inhaleSeconds = savedInhale > 0 ? savedInhale : 4

        let savedExhale = d.integer(forKey: "exhaleSeconds")
        exhaleSeconds = savedExhale > 0 ? savedExhale : 4

        let savedHold = d.double(forKey: "holdSeconds")
        holdSeconds = savedHold >= 0 ? savedHold : 0

        let savedOpacity = d.double(forKey: "opacity")
        opacity = savedOpacity > 0 ? savedOpacity : 0.85

        isCompactMode = d.bool(forKey: "isCompactMode")
        remainingSeconds = inhaleSeconds
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        phaseStartTime = Date()
        remainingSeconds = Int(ceil(currentPhaseSeconds))
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
        let total    = currentPhaseSeconds
        let f = total > 0 ? min(elapsed / total, 1.0) : 1.0
        remainingSeconds = max(Int(ceil(total - elapsed)), 0)

        switch phase {
        case .inhale:
            progress = Self.minScale + (Self.maxScale - Self.minScale) * f
        case .exhale:
            progress = Self.maxScale - (Self.maxScale - Self.minScale) * f
        case .holdAfterInhale:
            progress = Self.maxScale
        case .holdAfterExhale:
            progress = Self.minScale
        }

        guard elapsed >= total else { return }
        phase = phase.next
        phaseStartTime = Date()
        remainingSeconds = Int(ceil(currentPhaseSeconds))
    }

    deinit { timer?.invalidate() }
}
