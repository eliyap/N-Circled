//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 6/4/22.
//

import SwiftUI
import Combine

/// A `CoreAnimation` powered view for displaying `Spinner`s.
struct CASpinner: UIViewRepresentable {
    typealias UIViewType = CASpinnerView
    
    public let size: CGSize
    public let spinnerHolder: SpinnerHolder
    public let solution: Solution
    
    func makeUIView(context: Context) -> CASpinnerView {
        let view: UIViewType = .init(size: size, spinnerHolder: spinnerHolder, solution: solution)
        return view
    }
    
    func updateUIView(_ uiView: CASpinnerView, context: Context) {
        /// Nothing.
    }
}

final class CASpinnerView: UIView {
    
    public static let animationDuration: TimeInterval = 4.0
    
    /// Reflects `ObservableObject` `SpinnerHolder` value.
    private var spinners: [Spinner] = []
    
    /// Contains the conic gradient sublayers, in the same order as the corresponding spinners.
    private var layers: [CAShapeLayer] = []
    
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
                self?.spinners = spinners
                self?.layers = []
                self?.redrawSpinners()
                
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
    }
    
    private func highlight(spinner: Spinner?) -> Void {
        for sl in layers {
            sl.opacity = 0.5
            sl.lineWidth = 2
        }
        
        if let spinner = spinner {
            guard let idx = spinners.firstIndex(of: spinner) else {
                assert(false, "Could not find spinner \(spinner)")
                return
            }
            guard layers.indices ~= idx else {
                assert(false, "Could not match spinner index \(idx)")
                return
            }
            layers[idx].opacity = 1
            layers[idx].lineWidth = 5
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
    }
    
    private func redrawSpinners() {
        for sublayer in layer.sublayers ?? [] {
            sublayer.removeFromSuperlayer()
        }
        print(frame.size)
        addShape(size: size)
        addSpinners(size: size)
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
            
            layers.append(shapeLayer)
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

func makePath(diameter: CGFloat, lineWidth: CGFloat) -> CGPath {
    /// Center square at frame center.
    let rect = CGRect(
        x: lineWidth / 2,
        y: lineWidth / 2,
        width: diameter - lineWidth,
        height: diameter - lineWidth
    )
    return UIBezierPath(roundedRect: rect, cornerRadius: diameter/2).cgPath
}

func makeAnimation(
    offset: CGPoint,
    spinner: Spinner,
    counterSpinner: Spinner?
) -> CAAnimation {
    let animation = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.transform.rawValue)

    var transforms: [CATransform3D] = []
    var keyTimes: [NSNumber] = []
    
    /// Due to `CoreAnimation`'s high performance, we can afford many keyframes.
    /// A higher number mitigates issues arising from the "shortest rotation" behaviour in `CATransform`s.
    let numKeyframes: Int = 40
    
    for val in stride(from: 0, through: 1, by: 1 / CGFloat(numKeyframes)) {
        var radians = spinner.radians(proportion: val)
        radians -= counterSpinner?.radians(proportion: val) ?? 0
        let transform = CGAffineTransform(rotationAngle: radians)
            .concatenating(CGAffineTransform(translationX: offset.x, y: offset.y))
        transforms.append(CATransform3DMakeAffineTransform(transform))
        keyTimes.append(val as NSNumber)
    }
    animation.values = transforms
    animation.keyTimes = keyTimes
    animation.duration = CASpinnerView.animationDuration
    animation.autoreverses = false
    animation.repeatCount = .infinity
    
    return animation
}

func makeGradient(color: CGColor) -> CAGradientLayer {
    let gl = CAGradientLayer()
    gl.startPoint = CGPoint(x: 0.5, y: 0.5)
    gl.endPoint = CGPoint(x: 0.5, y: 0)
    gl.type = .conic
    gl.colors = [
        UIColor.systemBackground.cgColor,
        color,
    ]
    
    return gl
}
