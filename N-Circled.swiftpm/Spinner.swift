//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 8/4/22.
//

import SwiftUI

/// Represents a uniformly rotating circle with some size, at some phase.
struct Spinner {
    
    public let id: UUID = .init()
    
    /// Non-negative by convention.
    /// Normalized to `[0, 1]`.
    public var amplitude: CGFloat
    
    /// Discrete frequency.
    public var frequency: Int
    
    /// Unit: radians.
    /// Not bounded to `[0, 2pi]`.
    public var phase: CGFloat
    
    public var color: CGColor
    
    /// Finds the angle of the spinner from a [0, 1] proportion.
    /// The full [0, 1] range will show increments through `frequency` full turns, in radians.
    func radians(proportion: Double) -> Double {
        (proportion * 2 * .pi * CGFloat(frequency)) + phase
    }
    
    /// Returns a point within the unit circle, from a [0, 1] proportion.
    /// The full [0, 1] range will show increments through `frequency` full turns.
    func unitOffset(proportion: Double) -> CGPoint {
        let angle: CGFloat = self.radians(proportion: proportion)
        return CGPoint(
            x: amplitude * cos(angle),
            y: amplitude * sin(angle)
        )
    }
}

extension Spinner: Identifiable { }

extension Spinner: Equatable { }

extension Spinner: CustomStringConvertible {
    var description: String {
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
