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
