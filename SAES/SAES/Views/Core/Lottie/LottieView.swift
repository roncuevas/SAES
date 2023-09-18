import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    @Binding var animationFinished: Bool
    var name: String
    var animationSpeed: CGFloat?
    var loopMode: LottieLoopMode = .playOnce
    
    var animationView = LottieAnimationView()
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFit
        if let animationSpeed = animationSpeed {
            animationView.animationSpeed = animationSpeed
        }
        animationView.loopMode = loopMode
        animationView.play { _ in
            withAnimation {
                animationFinished = true
            }
        }
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {}
}
