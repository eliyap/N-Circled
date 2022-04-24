//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 8/4/22.
//

import SwiftUI

/// Represents a uniformly rotating circle with some size, at some phase.
struct Spinner {
    
    /// Allow private modification for automatic `Codable` synthesis.
    internal private(set) var id: UUID = .init()
    
    /// Non-negative by convention.
    /// Normalized to `[0, 1]`.
    public var amplitude: CGFloat
    
    /// Discrete frequency.
    public var frequency: Int
    
    /// Limited to keep puzzles simple.
    public static let allowedFrequencies = (-5)...(+5)
    
    /// Unit: radians.
    /// Not bounded to `[0, 2pi]`.
    public var phase: CGFloat
    
    public var color: SpinnerColor
    
    /// Given a proportion in the `[0, 1]` range, returns the angle in radians
    /// that the `Spinner` points to at that proportion of the way through
    /// `frequency` complete turns (starting at `phase`).
    public func radians(proportion: Double) -> Double {
        (proportion * 2 * .pi * CGFloat(frequency)) + phase
    }
    
    /// Returns a point within the unit circle, from a `[0, 1]` proportion.
    /// Iterating over `[0, 1]` will show increments through `frequency` full
    /// turns.
    public func unitOffset(proportion: Double) -> CGPoint {
        let angle: CGFloat = self.radians(proportion: proportion)
        return CGPoint(
            x: amplitude * cos(angle),
            y: amplitude * sin(angle)
        )
    }
    
    public var phaseInDegrees: Int {
        var phase = phase
        if phase < 0 { phase += 2 * .pi }
        return Int(phase * 360 / (2 * .pi))
    }
}

extension Spinner {
    /// Default line width for rendering.
    public static let lineWidth: CGFloat = 4.0
    
    /// Circle radius when `radius == 1.0`.
    public static let baseRadius: CGFloat = 200
}

extension Spinner: Identifiable { /** Automatically synthesized. **/ }

extension Spinner: Equatable { /** Automatically synthesized. **/ }

extension Spinner: Codable { /** Automatically synthesized. **/ }

extension Spinner: Hashable { /** Automatically synthesized. **/ }

extension Spinner: CustomDebugStringConvertible {
    var debugDescription: String {
        String(
            format: """
                Frequency %d, \
                Amplitude: %.3f, \
                Phase: %.3f
                """,
            frequency,
            amplitude,
            phase
        )
    }
}

extension Collection where Element == Spinner {
    /// Convenience method.
    /// Combines the offsets for all spinners at the same proportion.
    func vectorFor(proportion: Double) -> CGPoint {
        self
            .map { (spinner) in
                return spinner.unitOffset(proportion: proportion)
            }
            .reduce(CGPoint.zero, {
                return CGPoint(
                    x: $0.x + $1.x,
                    y: $0.y + $1.y
                )
            })
    }
}

extension Spinner {
    /// New spinner if one is not available, with a color determined by `index`.
    public static func defaultNew(index: Int) -> Spinner {
        let rawValue = index % SpinnerColor.allCases.count
        let color: SpinnerColor = {
            if let color = SpinnerColor(rawValue: rawValue) {
                return color
            } else {
                assert(false, "Invalid rawValue: \(rawValue)")
                return SpinnerColor.red
            }
        }()
        return Spinner(amplitude: 0.5, frequency: 1, phase: .zero, color: color)
    }
}
