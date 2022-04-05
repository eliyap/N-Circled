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

func testAccelerate() -> Void {
    /**
     * https://developer.apple.com/documentation/accelerate/vdsp/discretefouriertransform/3801973-init
     * The number of complex elements. 
     * For split-complex real-to-complex, the value of count must be 2ⁿ or `f * 2ⁿ`,
     * - `f` is 3, 5, or 15 
     * - `n` >= 4. 
     * 
     * For split-complex complex-to-complex, the value of count must be 2ⁿ or `f * 2ⁿ`,
     * - `f` is 3, 5, or 15 
     * - `n` >= 3. 
     * 
     * And for interleaved, the value of count must be `f * 2ⁿ`,
     * - `f` is 2, 3, 5, 3x3, 3x5, or 5x5,
     * - `n` >= 2.
     */
    let count = 2 * 2 * 2

    var reValues: [Float] = []
    var imValues: [Float] = []
    
    for index in 0..<count { 
        let angle: Float = .tau * Float(index) / Float(count)
        reValues.append(cos(angle))
        imValues.append(sin(angle))
    }

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
        return
    }
    
    // The `splitComplexOutput` tuple contains two arrays that represent the
    // real and imaginary parts of the output.
    let splitComplexOutput = dft.transform(
        real: reValues,
        imaginary: imValues
    )
    
    print(splitComplexOutput)
}
