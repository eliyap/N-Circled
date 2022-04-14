//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 14/4/22.
//

import UIKit

/// Given a collection of `Spinner`s, for which we want to take the
/// Inverse Discrete Fourier Transform, estimate the proportion of length
/// covered at the proportion of rotation at each of `numSamples` evenly
/// spaced steps.
func interpolateIdftProgress(
    spinners: [Spinner],
    numSamples: Int = 1000
) -> [(length: CGFloat, time: NSNumber)] {
    
    var result: [(CGFloat, NSNumber)] = []
    
    /// Estimated Cumulative Length.
    var ecl: CGFloat = .zero
    
    /// Finds velocity at some proportion (in the range `[0, 1]`)  through
    /// `frequency` complete turns.
    func velocity(of spinner: Spinner, at proportion: Double) -> CGPoint {
        let angle: CGFloat = spinner.radians(proportion: proportion)
        return CGPoint(
            x: CGFloat(spinner.frequency) * spinner.amplitude * -sin(angle),
            y: CGFloat(spinner.frequency) * spinner.amplitude * +cos(angle)
        )
    }
    
    /// Combines the velocities for all spinners at the same proportion.
    func velocity(of spinners: [Spinner], at proportion: Double) -> CGPoint {
        spinners
            .map { (spinner) in
                return velocity(of: spinner, at: proportion)
            }
            .reduce(CGPoint.zero, {
                return CGPoint(
                    x: $0.x + $1.x,
                    y: $0.y + $1.y
                )
            })
    }
    
    for sampleNo in 0..<numSamples {
        let proportion = CGFloat(sampleNo) / CGFloat(numSamples)
        let estVel = spinners.velocityFor(proportion: proportion)
        ecl += sqrt(estVel.squaredDistance(to: .zero))
        result.append((
            length: ecl,
            time: proportion as NSNumber
        ))
    }
    
    /// Normalize lengths.
    for sampleNo in 0..<numSamples {
        result[sampleNo].0 /= ecl
    }
    
    return result
}
