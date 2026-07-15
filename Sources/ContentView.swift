import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var engine: BreathingEngine

    var body: some View {
        if engine.isCompactMode {
            compactBody
        } else {
            circleBody
        }
    }

    private var compactBody: some View {
        ZStack {
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)

            RoundedRectangle(cornerRadius: 9)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            engine.phase.color.opacity(engine.isRunning ? engine.progress * 0.55 : 0.18),
                            engine.phase.color.opacity(engine.isRunning ? engine.progress * 0.20 : 0.06),
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(3)
        }
        .frame(width: 120, height: 28)
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .onTapGesture { engine.toggle() }
    }

    private var circleBody: some View {
        ZStack {
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)

            engine.windowTint.opacity(engine.isRunning ? 0.18 : 0.06)

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(engine.phase.color.opacity(0.10))
                        .frame(width: 120, height: 120)
                        .scaleEffect(engine.progress + 0.15)

                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    engine.phase.color.opacity(0.55),
                                    engine.phase.color.opacity(0.15),
                                ]),
                                center: .center,
                                startRadius: 8,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(engine.progress)

                    Circle()
                        .stroke(
                            engine.phase.color.opacity(0.7),
                            style: StrokeStyle(lineWidth: 2.5)
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(engine.progress)

                    VStack(spacing: 2) {
                        Text(engine.phase.label)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(engine.phase.color)

                        Text("\(engine.remainingSeconds)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                    }
                }

                Spacer()
            }
        }
        .frame(width: 180, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture { engine.toggle() }
    }
}

struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material
        v.blendingMode = blendingMode
        v.state = .active
        v.wantsLayer = true
        v.layer?.cornerRadius = 20
        v.layer?.masksToBounds = true
        return v
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
