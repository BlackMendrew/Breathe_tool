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
            Rectangle().fill(engine.breathColor.opacity(engine.brightness))

            HStack(spacing: 6) {
                Text(engine.phase.label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text("·")
                    .foregroundColor(.white.opacity(0.4))
                Text("\(engine.remainingSeconds)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
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
            Rectangle().fill(engine.breathColor.opacity(engine.brightness))

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            engine.breathColor.opacity(0.45),
                            engine.breathColor.opacity(0.08),
                        ]),
                        center: .center,
                        startRadius: 15,
                        endRadius: 65
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(engine.progress)

            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: 120, height: 120)
                .scaleEffect(engine.progress)

            VStack(spacing: 4) {
                Text(engine.phase.label)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                Text("\(engine.remainingSeconds)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
            }
        }
        .frame(width: 180, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture { engine.toggle() }
    }
}
