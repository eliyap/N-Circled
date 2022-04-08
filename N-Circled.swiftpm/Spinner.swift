//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 8/4/22.
//

import SwiftUI

/// Represents a uniformly rotating circle with some size, at some phase.
struct Spinner {
    
    let id: UUID = .init()
    
    /// Non-negative by convention.
    /// Normalized to `[0, 1]`.
    public let amplitude: CGFloat
    
    /// Discrete frequency.
    public let frequency: Int
    
    /// Unit: radians.
    /// Not bounded to `[0, 2pi]`.
    public let phase: CGFloat
    
    func radians(at date: Date) -> CGFloat {
        return (date.timeIntervalSince1970 * TimeInterval(frequency)) + phase
    }
    
    /// Unit: radians.
    func radians(proportion: Double) -> Double {
        (proportion * 2 * .pi * CGFloat(frequency)) + phase
    }
    
    func offset(at date: Date) -> CGPoint {
        let angle: CGFloat = (date.timeIntervalSince1970 * TimeInterval(frequency)) + phase
        return CGPoint(
            x: amplitude * cos(angle),
            y: amplitude * sin(angle)
        )
    }
    
    func offset(proportion: Double) -> CGPoint {
        let angle: CGFloat = self.radians(proportion: proportion)
        return CGPoint(
            x: amplitude * cos(angle),
            y: amplitude * sin(angle)
        )
    }
}

extension Spinner: Identifiable {
    
}

extension Spinner {
    func gradient(at date: Date) -> SwiftUI.Gradient {
        var proportion = radians(at: date) + .pi / 2
        proportion /= .pi * 2
        proportion = proportion.remainder(dividingBy: 1)
        proportion = proportion < 0
            ? proportion + 1
            : proportion
        
        
        let zeroColor = SwiftUI.Color(UIColor.red.withAlphaComponent(proportion))
        
        /// A tiny increment designed to create a sharp break between clear and opaque.
        /// If incrementing by this would exceed 1, don't do that.
        /// This fixes a runtime error `stops must be ordered.`
        let marginal = 0.001
        if proportion + marginal > 1 {
            proportion -= marginal
        }
        
        return SwiftUI.Gradient(stops: [
            .init(color: zeroColor, location: 0),
            .init(color: SwiftUI.Color(UIColor.clear), location: proportion),
            .init(color: SwiftUI.Color(UIColor.red), location: proportion + 0.001),
            .init(color: zeroColor, location: 1),
        ])
    }
    
    func draw(in context: inout GraphicsContext, date: Date, size: CGSize, offset: CGPoint) -> Void {
        let center = CGPoint(
            x: offset.x + size.width / 2,
            y: offset.y + size.height / 2
        )

        let shading: GraphicsContext.Shading = .conicGradient(
            gradient(at: date),
            center: center,
            angle: Angle(radians: 1) * radians(at: date)
        )

        let diameter = amplitude * min(size.width, size.height)
        let square = CGRect(
            origin: CGPoint(
                x: center.x - diameter / 2,
                y: center.y - diameter / 2
            ),
            size: CGSize(width: diameter, height: diameter)
        )
        let path = Circle().path(in: square)

        context.stroke(path, with: shading)
    }
}
