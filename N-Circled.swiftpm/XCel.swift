//
//  XCel.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 5/4/22.
//

import Foundation
import Accelerate

extension Float {
    static let tau: Float = Float.pi * 2
}

func testAccelerate(values: [Complex<Float>]) -> [Complex<Float>] {
    /**
     * https://developer.apple.com/documentation/accelerate/vdsp/discretefouriertransform/3801973-init
     * The value of count must be 2ⁿ or `f * 2ⁿ`,
     * - `f` is 3, 5, or 15
     * - `n` >= 3.
     */
    let count = values.count

    let dft: vDSP.DiscreteFourierTransform<Float>
    do {
        dft = try vDSP.DiscreteFourierTransform(
            previous: nil,
            count: count,
            direction: .forward,
            transformType: .complexComplex,
            ofType: Float.self
        )
    } catch (let error) {
        assert(false, "Construction of DFT failed with error \(error)")
        return []
    }
    
    let splitComplexOutput = dft.transform(
        real: values.map(\.real),
        imaginary: values.map(\.imaginary)
    )
    
    guard splitComplexOutput.real.count == splitComplexOutput.imaginary.count else {
        assert(false, "Unequal return size!")
        return []
    }
    
    var result: [Complex<Float>] = []
    for idx in splitComplexOutput.real.indices {
        result.append(Complex<Float>(
            re: splitComplexOutput.real[idx],
            im: splitComplexOutput.imaginary[idx]
        ))
    }
    
    return result
}
