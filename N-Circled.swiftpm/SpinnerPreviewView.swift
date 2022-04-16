//
//  SpinnerPreviewView.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 16/4/22.
//

import UIKit
import Combine

final class SpinnerPreviewView: UIView {
    
    public static let animationDuration: TimeInterval = 4.0
    
    /// Reflects `ObservableObject` `SpinnerHolder` value.
    private var spinners: [Spinner] = []
    
    /// Contains the circle mask sublayers, in the same order as the corresponding spinners.
    private var circleLayers: [CAShapeLayer] = []
    
    /// Sublayers we have added, and may wish to discard.
    private var sublayers: [CALayer] = []
    
    /// Solution to the current puzzle.
    private let solution: Solution
    
    private var observers: Set<AnyCancellable> = []
    
    /// View size as measured by `GeometryReader`.
    private let size: CGSize
    
    /// Composed IDFT sublayers.
    let strokeStartLayer: CAShapeLayer
    let strokeEndLayer: CAShapeLayer
    
    init(size: CGSize, spinnerHolder: SpinnerHolder, solution: Solution) {
        self.size = size
        self.strokeStartLayer = .init()
        self.strokeEndLayer = .init()
        self.solution = solution
        super.init(frame: .zero)
        
        addShape(size: size)
        addSpinners(size: size)
        
        let spinnersObserver = spinnerHolder.$spinners
            .sink(receiveValue: { [weak self] spinners in
                guard let self = self else { return }
                self.spinners = spinners
                self.circleLayers = []
                self.redrawSpinners()
                
                print("score", solution.score(attempt: spinners, samples: 1000))
            })
        spinnersObserver.store(in: &observers)
        
        let highlightObserver = spinnerHolder.$highlighted
            .sink(receiveValue: highlight)
        highlightObserver.store(in: &observers)
        
        /// Addresses an issue where `CoreAnimation` animations cease on backgrounding.
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [weak self] _ in
            self?.redrawSpinners()
        })
        
        let confettiView = ConfettiView()
        addSubview(confettiView)
        confettiView.startConfetti()

    }
    
    private func highlight(spinner: Spinner?) -> Void {
        for sl in circleLayers {
            sl.opacity = 0.5
            sl.lineWidth = 2
        }
        
        if let spinner = spinner {
            guard let idx = spinners.firstIndex(of: spinner) else {
                assert(false, "Could not find spinner \(spinner)")
                return
            }
            guard circleLayers.indices ~= idx else {
                assert(false, "Could not match spinner index \(idx)")
                return
            }
            circleLayers[idx].opacity = 1
            circleLayers[idx].lineWidth = 5
        }
    }
    
    private func drawSolutionLayer() {
        let solutionLayer: CAShapeLayer = .init()
        solutionLayer.path = getIdftPath(spinners: solution.spinners, frameSize: size)
        solutionLayer.fillColor = nil
        solutionLayer.strokeColor = UIColor.label.cgColor
        solutionLayer.opacity = 0.5
        solutionLayer.lineWidth = 3
        solutionLayer.lineDashPattern = [10, 10]
        layer.addSublayer(solutionLayer)
        sublayers.append(solutionLayer)
    }
    
    private func redrawSpinners() {
        for sublayer in sublayers {
            sublayer.removeFromSuperlayer()
        }
        addShape(size: size)
        addSpinners(size: size)
        drawSolutionLayer()
    }
    
    private func addShape(size: CGSize) -> Void {
        let approxPath: CGPath = getIdftPath(spinners: spinners, frameSize: self.size)
        
        strokeStartLayer.path = approxPath
        strokeStartLayer.strokeColor = UIColor.systemTeal.cgColor
        strokeStartLayer.fillColor = nil
        strokeStartLayer.lineWidth = 3
        
        strokeEndLayer.path = approxPath
        strokeEndLayer.strokeColor = UIColor.systemTeal.cgColor
        strokeEndLayer.fillColor = nil
        strokeEndLayer.lineWidth = 3
        
        addIdftAnimation(spinners: spinners, startLayer: strokeStartLayer, endLayer: strokeEndLayer)
        
        layer.addSublayer(strokeStartLayer)
        layer.addSublayer(strokeEndLayer)
        sublayers.append(contentsOf: [strokeStartLayer, strokeEndLayer])
    }
    
    private func addSpinners(size: CGSize) -> Void {
        let baseRadius: CGFloat = 200
        
        var prevLayer: CALayer = layer
        var prevFrameSize: CGSize = size
        var prevSpinner: Spinner? = nil
        
        for index in spinners.indices {
            let spinner = spinners[index]
            
            let diameter: CGFloat = baseRadius * spinner.amplitude
            let layerFrame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            
            /// Create layers.
            let gradientLayer = makeGradient(color: spinner.color)
            gradientLayer.frame = layerFrame
            
            let newLayer = CALayer()
            newLayer.frame = layerFrame
            
            let lineWidth: CGFloat = 2
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = layerFrame
            shapeLayer.path = makePath(diameter: diameter, lineWidth: lineWidth)
            shapeLayer.fillColor = nil
            shapeLayer.strokeColor = UIColor.black.cgColor
            shapeLayer.lineWidth = lineWidth
            
            /// Assemble layers.
            newLayer.addSublayer(gradientLayer)
            prevLayer.addSublayer(newLayer)
            sublayers.append(contentsOf: [gradientLayer, newLayer])
            
            /// https://developer.apple.com/documentation/quartzcore/calayer/1410861-mask
            /// > The layer you assign to this property **must not have a superlayer.**
            gradientLayer.mask = shapeLayer
            
            /// Add offset and rotation.
            var offset = CGPoint(
                x: prevFrameSize.width/2 - diameter/2,
                y: -diameter/2
            )
            if index == spinners.startIndex {
                offset.y += prevFrameSize.height / 2
            }
            let animation = makeAnimation(
                offset: offset,
                spinner: spinner,
                counterSpinner: prevSpinner
            )
            newLayer.add(animation, property: .transform)
            
            /// Prepare for next iteration.
            prevLayer = newLayer
            prevFrameSize = layerFrame.size
            prevSpinner = spinner
            
            circleLayers.append(shapeLayer)
        }
    }
    
    deinit {
        for observer in observers {
            observer.cancel()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
