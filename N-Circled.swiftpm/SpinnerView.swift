//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 5/4/22.
//

import SwiftUI

struct SpinnerView: View {
    
    public let dftResults: [Complex<Float>] = test()
    
    private let spinners: [Spinner] = [
        .init(amplitude: 0.25, frequency: 1, phase: .zero),
        .init(amplitude: 0.50, frequency: 2, phase: .zero),
        .init(amplitude: 0.75, frequency: 3, phase: .zero),
        .init(amplitude: 1.00, frequency: 4, phase: .zero),
    ]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { (context, size) in
                let location = dftResults.fourierSeriesResult(date: timeline.date, size: size)
                context.draw(Image(systemName: "heart"), at: location)
                
                var offset: CGPoint = .zero
                for spinner in spinners {
                    spinner.draw(in: &context, date: timeline.date, size: size, offset: offset)
//                    offset.x += spinner.offset(at: timeline.date).x * min(size.height, size.height)
//                    offset.y += spinner.offset(at: timeline.date).y * min(size.height, size.height)
                }
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(spinners) { spinner in
                        Canvas { (context, size) in
                            spinner.draw(in: &context, date: timeline.date, size: size, offset: .zero)
                        }
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
                .frame(height: 100)
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
    
    func offset(proportion: Double) -> CGPoint {
        let angle: CGFloat = (proportion * 2 * .pi * CGFloat(frequency)) + phase
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
