import SwiftUI

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
            engine.phase.color.opacity(engine.isRunning ? engine.progress * 0.65 : 0.12)

            HStack(spacing: 6) {
                Text(engine.phase.label)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text("·")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(.white.opacity(0.5))

                Text("\(engine.remainingSeconds)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
            }
        }
        .frame(width: 200, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onTapGesture { engine.toggle() }
    }

    private var circleBody: some View {
        ZStack {
            engine.windowTint.opacity(engine.isRunning ? 0.15 : 0.05)

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
