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
        spinnerHolder.points = points
        
        /// Clear canvas after each stroke.
        canvasView.drawing = .init()
    }
    
    private func strokePoints(canvasView: PKCanvasView) -> [CGPoint] {
        /// Due to `Accelerate` requirements, must be a power of 2.
        let sampleCount = 8
        
        var points: [CGPoint] = []
        
        for stroke in canvasView.drawing.strokes {
            guard stroke.path.isEmpty == false else { continue }

//            let strokeLength = stroke.path.distance(from: stroke.path.startIndex, to: stroke.path.endIndex)
//
//            for index in 0..<sampleCount {
//
//                let proportion = CGFloat(index) / CGFloat(sampleCount)
//                let location = stroke.path.interpolatedLocation(at: CGFloat(stroke.path.endIndex) * proportion)
//                points.append(location)
//            }
            
//            let locs = stroke.path.interpolatedPoints(by: .time(0.001))
//                .map(\.location)
//            var count = 4096
//            while count >= locs.count {
//                count /= 2
//            }
//
//            points.append(contentsOf: locs[..<count])
//            print("count", count)
        }
        
        let baseRadius: CGFloat = 200

//        for index in 0..<sampleCount {
//            let angle: CGFloat = .pi * 2 * CGFloat(index) / CGFloat(sampleCount)
//            points.append(CGPoint(
//                x: cos(angle + .pi / 2) * baseRadius,
//                y: sin(angle + .pi / 2) * baseRadius
//            ))
//        }
        
        points = [
            CGPoint(x: 0.0000 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.0625 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.1250 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.1875 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.2500 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.3125 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.3750 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.4375 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.5000 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.5625 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.6250 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.6875 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.7500 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.8125 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.8750 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 0.9375 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.0000 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.0625 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.1250 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.1875 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.2500 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.3125 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.3750 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.4375 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.5000 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.5625 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.6250 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.6875 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.7500 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.8125 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.8750 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 0.9375 * baseRadius),
            CGPoint(x: 1.0000 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.9375 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.8750 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.8125 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.7500 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.6875 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.6250 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.5625 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.5000 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.4375 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.3750 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.3125 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.2500 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.1875 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.1250 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.0625 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 1.0000 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.9375 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.8750 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.8125 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.7500 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.6875 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.6250 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.5625 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.5000 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.4375 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.3750 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.3125 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.2500 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.1875 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.1250 * baseRadius),
            CGPoint(x: 0.0000 * baseRadius, y: 0.0625 * baseRadius),
        ]
        
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
