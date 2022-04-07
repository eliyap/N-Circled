//
//  DoodleView.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 5/4/22.
//

import SwiftUI
import UIKit
import PencilKit

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
        print(strokePoints(canvasView: canvasView).count)
    }
    
    private func strokePoints(canvasView: PKCanvasView) -> [CGPoint] {
        let epsilon = 0.001
        
        var points: [CGPoint] = []
        
        for stroke in canvasView.drawing.strokes {
            guard stroke.path.isEmpty == false else { continue }
            for proportion in stride(from: 0.0, to: 1.0, by: epsilon) {
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
