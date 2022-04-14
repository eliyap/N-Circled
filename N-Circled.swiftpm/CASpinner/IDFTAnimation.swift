//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 14/4/22.
//

import UIKit

func addIdftAnimation(
    spinners: [Spinner],
    startLayer: CAShapeLayer,
    endLayer: CAShapeLayer
) {
    let animationValues = interpolateIdftProgress(spinners: spinners)
    let previewLength: CGFloat = 0.1
            
    let unmodified = animationValues
    var flooredReduced = animationValues
    
    var dipped = animationValues
    var wrappedReduced = animationValues
    
    /// Adjust values.
    for idx in 0..<animationValues.count {
        /// Advance `strokeStrart` by length.
        flooredReduced[idx].length -= previewLength
        wrappedReduced[idx].length -= previewLength
        
        if flooredReduced[idx].length < 0 {
            flooredReduced[idx].length = 0
        }
        if wrappedReduced[idx].length < 0 {
            wrappedReduced[idx].length += 1
            dipped[idx].length = 1
        }
    }
    
    let sslStartAnim = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.strokeStart.rawValue)
    let sslEndAnim = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.strokeEnd.rawValue)
    let selStartAnim = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.strokeStart.rawValue)
    let selEndAnim = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.strokeEnd.rawValue)
    
    for (steps, anim) in [
        (flooredReduced, sslStartAnim),
        (unmodified,     sslEndAnim),
        (wrappedReduced, selStartAnim),
        (dipped,         selEndAnim),
    ] {
        anim.values = steps.map(\.length)
        anim.keyTimes = steps.map(\.time)
        
        anim.duration = 4
        anim.autoreverses = false
        anim.repeatCount = .infinity
    }
    
    startLayer.add(sslStartAnim, property: .strokeStart)
    startLayer.add(sslEndAnim, property: .strokeEnd)
    
    endLayer.add(selStartAnim, property: .strokeStart)
    endLayer.add(selEndAnim, property: .strokeEnd)
}

/// Given a collection of `Spinner`s, for which we want to take the
/// Inverse Discrete Fourier Transform, estimate the proportion of length
/// covered at the proportion of rotation at each of `numSamples` evenly
/// spaced steps.
fileprivate func interpolateIdftProgress(
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
        let estVel = velocity(of: spinners, at: proportion)
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
