//
//  ShimmerEffect.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//

import SwiftUI
struct ShimmerEffect: ViewModifier {
    @State private var currentTime: Double = Date().timeIntervalSince1970
    @State private var timer: Timer? = nil
    private let delay: Double
    
    init(delay: Int) {
        self.delay = Double(delay)
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Color.customWhite
                    .opacity(calculateOpacity(delay: delay))
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            )
            .onAppear {
                if timer == nil {
                    timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
                        currentTime = Date().timeIntervalSince1970 // Update time on each tick
                    }
                }
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
    }
    
    private func calculateOpacity(delay: Double) -> Double {
        let baseOpacity = 0.6
        let totalOpacityMax = 0.23
        let range = 0.5
        let frequency = 1.4
        let timeToRadianTime = currentTime * frequency * .pi + delay
        let opacity = (sin(timeToRadianTime) * range) * totalOpacityMax + baseOpacity
        return opacity
    }
}

extension View {
    func shimmer(delay: Int = 0) -> some View {
        self.modifier(ShimmerEffect(delay: delay))
    }
}
