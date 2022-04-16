//
//  GradingView.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 16/4/22.
//

import SwiftUI
import Combine

/// A `CoreAnimation` powered view for displaying `Spinner`s.
struct GradingView: UIViewRepresentable {
    typealias UIViewType = UIGradingView
    
    public let size: CGSize
    public let spinnerHolder: SpinnerHolder
    public let solution: Solution
    
    func makeUIView(context: Context) -> UIGradingView {
        let view: UIViewType = .init(size: size, spinnerHolder: spinnerHolder, solution: solution)
        return view
    }
    
    func updateUIView(_ uiView: UIGradingView, context: Context) {
        /// Nothing.
    }
}

final class UIGradingView: UIView {
    
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
        
        let gradingObserver = spinnerHolder.$isGrading
            .sink(receiveValue: { [weak self] isGrading in
                #warning("TODO")
            })
        
        /// Addresses an issue where `CoreAnimation` animations cease on backgrounding.
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [weak self] _ in
            self?.redrawSpinners()
        })
        
        layer.borderColor = UIColor.green.cgColor
        layer.borderWidth = 2
        print("size \(size)")
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
        
        let animationValues = interpolateIdftProgress(spinners: spinners)
                
        let anim = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.strokeEnd.rawValue)
        
        anim.values = animationValues.map(\.length)
        anim.keyTimes = animationValues.map(\.time)
        
        anim.duration = CASpinnerView.animationDuration
        anim.autoreverses = false
        anim.repeatCount = .infinity
        
        strokeStartLayer.lineCap = .round
        
        strokeStartLayer.add(anim, property: .strokeEnd)
        
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
