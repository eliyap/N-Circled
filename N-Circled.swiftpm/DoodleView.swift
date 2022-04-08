//
//  DoodleView.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 5/4/22.
//

import SwiftUI
import UIKit
import PencilKit
import ComplexModule

struct DoodleView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIDoodleViewController
    
    public var spinnerHolder: SpinnerHolder
    
    func makeUIViewController(context: Context) -> UIDoodleViewController {
        let vc: UIViewControllerType = .init(spinnerHolder: spinnerHolder)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIDoodleViewController, context: Context) {
        /// Nothing.
    }
}

final class UIDoodleViewController: UIViewController {
    
    private let doodleView: UIDoodleView
    private let spinnerHolder: SpinnerHolder
    
    init(spinnerHolder: SpinnerHolder) {
        self.doodleView = .init()
        self.spinnerHolder = spinnerHolder
        super.init(nibName: nil, bundle: nil)
        
        self.view = doodleView
        doodleView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIDoodleViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        /// Prevent infinite loop from clearing canvas.
        guard canvasView.drawing.strokes.isEmpty == false else { return }
        
        let points = strokePoints(canvasView: canvasView)
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
        
        spinnerHolder.spinners = spinners
        
        /// Clear canvas after each stroke.
        canvasView.drawing = .init()
    }
    
    private func strokePoints(canvasView: PKCanvasView) -> [CGPoint] {
        /// Due to `Accelerate` requirements, must be a power of 2.
        let sampleCount = 8
        
        var points: [CGPoint] = []
        
        for stroke in canvasView.drawing.strokes {
            guard stroke.path.isEmpty == false else { continue }
            for index in 0..<sampleCount {
                let proportion = CGFloat(index) / CGFloat(sampleCount)
                let location = stroke.path.interpolatedLocation(at: CGFloat(stroke.path.endIndex) * proportion)
                points.append(location)
            }
        }
        
        return points
    }
}

final class UIDoodleView: PKCanvasView {
    init() {
        super.init(frame: .zero)
        
        /// Permit finger input by default.
        self.drawingPolicy = .anyInput
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
