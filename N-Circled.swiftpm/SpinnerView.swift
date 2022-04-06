//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 5/4/22.
//

import SwiftUI

struct SpinnerView: View {
    
    public let dftResults: [Complex<Float>] = test()
    
    private let spinner: Spinner? = .init(
        amplitude: 1,
        frequency: 1,
        phase: .zero
    )
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { (context, size) in
                let location = dftResults.fourierSeriesResult(date: timeline.date, size: size)
                context.draw(Image(systemName: "heart"), at: location)
                
                if let spinner = spinner {
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)


                    var loc = spinner.radians(at: timeline.date).remainder(dividingBy: 1)
                    loc = loc < 0 ? loc + 1 : loc
                    let shading: GraphicsContext.Shading = .conicGradient(
                        spinner.gradient(at: timeline.date),
                        center: center,
                        angle: Angle(radians: 1) * spinner.radians(at: timeline.date)
                    )

                    let diameter = spinner.amplitude * min(size.width, size.height)
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
        }
    }
}

extension Collection where Element == Complex<Float> {
    func fourierSeriesResult(date: Date, size: CGSize) -> CGPoint {
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        for (idx, value) in self.enumerated() {
            /// Scale time by idx (i.e. discrete frequency).
            let angle = date.timeIntervalSince1970 * TimeInterval(idx)
            
            x += CGFloat(cos(angle)) * CGFloat(value.magnitude)
            y += CGFloat(sin(angle)) * CGFloat(value.magnitude)
        }

        x = x / CGFloat(self.count)
        y = y / CGFloat(self.count)

        /// Scale to shorter side.
        let scale = Swift.min(size.width, size.height)
        return CGPoint(
            x: x * scale / 2 + size.width / 2,
            y: y * scale / 2 + size.height / 2
        )
    }
}

/// Represents a uniformly rotating circle with some size, at some phase.
struct Spinner {
    /// Non-negative by convention.
    /// Normalized to `[0, 1]`.
    let amplitude: CGFloat
    
    /// Discrete frequency.
    let frequency: Int
    
    /// Unit: radians.
    /// Not bounded to `[0, 2pi]`.
    let phase: CGFloat
    
    func radians(at date: Date) -> CGFloat {
        return (date.timeIntervalSince1970 * TimeInterval(frequency)) + phase
    }
    
    func angle(at date: Date) -> Angle {
        .init(radians: radians(at: date))
    }
    
    func offset(at date: Date) -> CGPoint {
        let angle: CGFloat = (date.timeIntervalSince1970 * TimeInterval(frequency)) + phase
        return CGPoint(
            x: amplitude * cos(angle),
            y: amplitude * sin(angle)
        )
    }
}

extension Spinner {
    func gradient(at date: Date) -> SwiftUI.Gradient {
        var proportion = radians(at: date)
        proportion /= .pi * 2
        proportion = proportion.remainder(dividingBy: 1)
        proportion = proportion < 0
            ? proportion + 1
            : proportion
        
        
        let zeroColor = SwiftUI.Color(UIColor.red.withAlphaComponent(proportion))
        
        return SwiftUI.Gradient(stops: [
            .init(color: zeroColor, location: 0),
            .init(color: SwiftUI.Color(UIColor.clear), location: proportion),
            .init(color: SwiftUI.Color(UIColor.red), location: proportion + 0.001),
            .init(color: zeroColor, location: 1),
        ])
    }
}
