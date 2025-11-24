import SwiftUI
import UIKit

// UIKit wrapper for glass effect that works properly with rotation
struct GlassEffectView: UIViewRepresentable {
    var cornerRadius: CGFloat
    var tint: UIColor?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIGlassEffect())
        view.layer.cornerRadius = cornerRadius
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        
        if let tint = tint {
            let backgroundView = UIView()
            backgroundView.backgroundColor = tint
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.contentView.insertSubview(backgroundView, at: 0)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.layer.cornerRadius = cornerRadius
    }
}

struct SubtitleView: View {
    let subtitle: Subtitle?
    
    var body: some View {
        if let subtitle = subtitle {
            VStack(spacing: 4) {
                Text(subtitle.japanese)
                    .font(.system(size: 24, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(subtitle.english)
                    .font(.system(size: 14, weight: .regular))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                GlassEffectView(cornerRadius: 16, tint: nil)
            )
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }
}
