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

            HStack(spacing: 8) {
                Text(engine.phase.label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.7))
                            .frame(width: max(geo.size.width * engine.fraction, 6), height: 6)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .padding(.horizontal, 10)
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
