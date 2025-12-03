//
//  LottieAnimationView.swift
//  SpendLess
//
//  Reusable SwiftUI wrapper for Lottie animations
//

import SwiftUI
import Lottie

struct LottieAnimationView: View {
    let animationName: String
    var loopMode: LottieLoopMode = .loop
    
    var body: some View {
        LottieView(animation: .named(animationName))
            .playing(loopMode: loopMode)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        LottieAnimationView(animationName: "starSad")
            .frame(height: 200)
        
        LottieAnimationView(animationName: "brain", loopMode: .playOnce)
            .frame(height: 200)
    }
}

