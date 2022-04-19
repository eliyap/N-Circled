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
    
    public var color: SpinnerColor
    
    /// Given a proportion in the `[0, 1]` range, returns the angle in radians
    /// that the `Spinner` points to at that proportion of the way through `frequency`
    /// complete turns (starting at `phase`).
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

extension Spinner: Identifiable { /** Automatically synthesized. **/ }

extension Spinner: Equatable { /** Automatically synthesized. **/ }

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

extension Spinner {
    /// New spinner if one is not available.
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

public enum SpinnerColor: Int, CaseIterable {
    case blue
    case purple
    case red
    case yellow
    case green
    
    var cgColor: CGColor {
        switch self {
            case .green: 
                return UIColor.SCGreen.cgColor
            case .yellow: 
                return UIColor.SCYellow.cgColor
            case .red: 
                return UIColor.SCRed.cgColor
            case .purple: 
                return UIColor.SCPurple.cgColor
            case .blue: 
                return UIColor.SCBlue.cgColor
        }
    }
}


extension UIColor {
    /// SC could be https://sixcolors.com/
    /// or Southern California, or SpinnerColor. Pick one.
    /// Permission obtained from Jason Snell via email.
    static let SCGreen = UIColor(named: "SC_Green")!
    static let SCYellow = UIColor(named: "SC_Yellow")!
    static let SCOrange = UIColor(named: "SC_Orange")!
    static let SCRed = UIColor(named: "SC_Red")!
    static let SCPurple = UIColor(named: "SC_Purple")!
    static let SCBlue = UIColor(named: "SC_Blue")!
}

let SCColors: [UIColor] = [
    .SCGreen,
    .SCYellow,
    .SCOrange,
    .SCRed,
    .SCPurple,
    .SCBlue,
]
