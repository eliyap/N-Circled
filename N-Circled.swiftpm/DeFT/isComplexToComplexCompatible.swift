//
//  isComplexToComplexCompatible.swift
//  
//
//  Created by Secret Asian Man Dev on 9/4/22.
//

import Foundation

extension Int {
    /** Whether this is a valid count for `Accelerate` `complexToComplex` calls.
     *
     * https://developer.apple.com/documentation/accelerate/vdsp/discretefouriertransform/3801973-init
     * The value of count must be 2ⁿ or `f * 2ⁿ`,
     * - `f` is 3, 5, or 15
     * - `n` >= 3.
     */
    var isComplexToComplexCompatible: Bool {
        var num = self
        
        /// Number of times 2 has been factored out.
        var twoFactors = 0
        
        while num.isMultiple(of: 2) {
            num /= 2
            twoFactors += 1
        }
        
        guard twoFactors >= 3 else { return false }
        return (num == 1) || (num == 3) || (num == 5) || (num == 15)
    }
}

extension Collection {
    /** Whether this contains a valid number of elements for `Accelerate` `complexToComplex` calls.
     *
     * https://developer.apple.com/documentation/accelerate/vdsp/discretefouriertransform/3801973-init
     * The value of count must be 2ⁿ or `f * 2ⁿ`,
     * - `f` is 3, 5, or 15
     * - `n` >= 3.
     */
    var isComplexToComplexCompatible: Bool {
        count.isComplexToComplexCompatible
    }
}
