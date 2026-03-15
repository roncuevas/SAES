import SwiftUI
import UIKit

struct EmojiCelebrationView: View {
    private let emojis = ["❤️", "❤️", "❤️", "☕", "☕", "☕", "🎉", "⭐", "💛", "🥳", "🙏", "✨"]
    @State private var particles: [EmojiParticle] = []
    @State private var isAnimating = false
    @State private var showTitle = false
    @State private var isFadingOut = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(AppConstants.UserDefaultsKeys.hapticFeedbackEnabled) private var hapticFeedbackEnabled = true
    var onFinished: () -> Void = {}

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(isFadingOut ? 0 : 0.45)
                    .ignoresSafeArea()

                ForEach(particles) { particle in
                    Text(particle.emoji)
                        .font(.system(size: particle.size))
                        .position(
                            x: geo.size.width / 2 + (isAnimating ? particle.endX : particle.startX),
                            y: geo.size.height + (isAnimating ? particle.endY : particle.startY)
                        )
                        .opacity(isFadingOut ? 0 : 1)
                        .scaleEffect(isAnimating ? particle.endScale : 1.0)
                        .rotationEffect(.degrees(isAnimating ? particle.rotation : 0))
                }

                Text(Localization.donorCelebrationTitle)
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .scaleEffect(showTitle ? 1.0 : 0.3)
                    .opacity(showTitle && !isFadingOut ? 1 : 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
            }
            .task {
                generateParticles(screenHeight: geo.size.height, screenWidth: geo.size.width)
                if hapticFeedbackEnabled {
                    triggerHapticBurst()
                }

                let moveDuration = reduceMotion ? 0.5 : 4.0
                withAnimation(.easeInOut(duration: moveDuration)) {
                    isAnimating = true
                }
                withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                    showTitle = true
                }

                // Wait for particles to finish moving
                try? await Task.sleep(for: .seconds(moveDuration))

                // Hold everything visible
                let holdDuration = reduceMotion ? 0.5 : 3.0
                try? await Task.sleep(for: .seconds(holdDuration))

                // Slow fade out
                withAnimation(.easeIn(duration: 2.0)) {
                    isFadingOut = true
                }

                try? await Task.sleep(for: .seconds(2.0))
                onFinished()
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func generateParticles(screenHeight: CGFloat, screenWidth: CGFloat) {
        particles = (0..<120).map { _ in
            let startYPos = CGFloat.random(in: -screenHeight ... 0)
            let startXPos = CGFloat.random(in: -screenWidth * 0.5 ... screenWidth * 0.5)
            return EmojiParticle(
                emoji: emojis.randomElement() ?? "❤️",
                startX: startXPos,
                startY: startYPos,
                endX: startXPos + CGFloat.random(in: -40...40),
                endY: startYPos - CGFloat.random(in: 40...120),
                size: CGFloat.random(in: 28...56),
                rotation: Double.random(in: -45...45),
                endScale: CGFloat.random(in: 0.7...1.3)
            )
        }
    }

    private func triggerHapticBurst() {
        let notification = UINotificationFeedbackGenerator()
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        let medium = UIImpactFeedbackGenerator(style: .medium)
        let light = UIImpactFeedbackGenerator(style: .light)

        notification.notificationOccurred(.success)
        heavy.impactOccurred()

        let delays: [(TimeInterval, UIImpactFeedbackGenerator)] = [
            (0.15, medium), (0.3, heavy), (0.6, light),
            (1.0, medium), (1.5, light), (2.0, medium),
        ]
        for (delay, generator) in delays {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                generator.impactOccurred()
            }
        }
    }
}

private struct EmojiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let size: CGFloat
    let rotation: Double
    let endScale: CGFloat
}
