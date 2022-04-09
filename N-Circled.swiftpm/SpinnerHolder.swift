//
//  SpinnerHolder.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 9/4/22.
//

import SwiftUI
import ComplexModule

final class SpinnerHolder: ObservableObject {
    
    @Published var spinners: [Spinner] = []
    
    @Published var points: [CGPoint] = []
    
    init() {
        
    }
}

func makeSpinners(from points: [CGPoint]) -> [Spinner]? {
    let values = points.map { point in
        return Complex<Float>(Float(point.x), Float(point.y))
    }
    let dft = testAccelerate(values: values)
    var spinners: [Spinner] = []
    for (idx, complex) in dft.enumerated() {
        guard complex.phase.isNaN == false else { continue }
        
        var amp = CGFloat(complex.length) / CGFloat(values.count)
        amp /= 100
        #warning("temp damper")
        
        let spinner = Spinner(
            amplitude: amp,
            frequency: idx,
            phase: CGFloat(complex.phase)
        )
        #warning("todo fix phase")
        
        spinners.append(spinner)
    }
    
    if spinners.isEmpty == false {
        /// Remove the first, zero frequency component.
        return Array(spinners[1...])
    } else {
        return nil
    }
}
