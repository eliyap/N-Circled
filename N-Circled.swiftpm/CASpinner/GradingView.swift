//
//  GradingView.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 16/4/22.
//

import SwiftUI

/// A `CoreAnimation` powered view for displaying `Spinner`s.
struct GradingView: UIViewRepresentable {
    typealias UIViewType = UIGradingView
    
    public let size: CGSize
    public let spinnerHolder: SpinnerHolder
    public let solution: Solution
    public let gradingCompletionCallback: (Bool) -> Void
    
    func makeUIView(context: Context) -> UIGradingView {
        let view: UIViewType = .init(size: size, spinnerHolder: spinnerHolder, solution: solution, onGradingCompletion: gradingCompletionCallback)
        return view
    }
    
    func updateUIView(_ uiView: UIGradingView, context: Context) {
        guard size != uiView.size else {
            return
        }
        uiView.redraw(in: size)
    }
}

final class UIGradingView: UIView {
    
    public static let animationDuration: TimeInterval = 3.0
    
    /// Reflects `ObservableObject` `SpinnerHolder` value.
    private var spinners: [Spinner] = []
    
    /// Contains the circle mask sublayers, in the same order as the corresponding spinners.
    private var circleLayers: [CAShapeLayer] = []
    
    /// Sublayers we have added, and may wish to discard.
    private var sublayers: [CALayer] = []
    
    /// Solution to the current puzzle.
    private let solution: Solution
    
    /// View size as measured by `GeometryReader`.
    public private(set) var size: CGSize
    
    /// Composed IDFT sublayers.
    private let idftLayer: CAShapeLayer
    
    /// Shows the player's score.
    private weak var scoreStrokeLayer: CAShapeLayer? = nil
    
    private var gradingCompletionCallback: (Bool) -> Void
    
    init(size: CGSize, spinnerHolder: SpinnerHolder, solution: Solution, onGradingCompletion gradingCompletionCallback: @escaping (Bool) -> Void) {
        self.size = size
        self.idftLayer = .init()
        self.solution = solution
        self.gradingCompletionCallback = gradingCompletionCallback
        super.init(frame: .zero)
        
        let spinners = spinnerHolder.spinnerSlots.compactMap(\.spinner)
        self.spinners = spinners
        
        redraw(in: size)
    }
    
    public func redraw(in size: CGSize) -> Void {
        self.size = size
        for sublayer in sublayers {
            sublayer.removeFromSuperlayer()
        }
        addShape(size: size)
        addSpinners(size: size)
        drawSolutionLayer()
        drawScoreBar()
        animateScore()
    }
    
    /// - Note: `completion` is called after the delay, not the end of the animation.
    private func delayAnimation(layer: CALayer?, animation: CAAnimation, property: CALayer.AnimatableProperty, completion: @escaping () -> ()) -> Void {
        DispatchQueue.main.asyncAfter(deadline: .now() + PuzzleView.transitionDuration, execute: {
            layer?.add(animation, property: property)
            completion()
        })
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
    
    private func addShape(size: CGSize) -> Void {
        let approxPath: CGPath = getIdftPath(spinners: spinners, frameSize: self.size)
        
        idftLayer.path = approxPath
        idftLayer.strokeColor = UIColor.systemTeal.cgColor
        idftLayer.fillColor = nil
        idftLayer.lineWidth = 3
        idftLayer.lineCap = .round
        
        let animationValues = interpolateIdftProgress(spinners: spinners)
        let anim = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.strokeEnd.rawValue)
        anim.values = animationValues.map(\.length)
        anim.keyTimes = animationValues.map(\.time)
        anim.duration = UIGradingView.animationDuration
        
        /// Hide stroke when transitioning in.
        idftLayer.strokeEnd = 0
        self.delayAnimation(layer: idftLayer, animation: anim, property: .strokeEnd, completion: { [weak self] in
            guard let self = self else { return }
            
            /// Show stroke after animation completes.
            self.idftLayer.strokeEnd = 1
        })
        
        layer.addSublayer(idftLayer)
        sublayers.append(idftLayer)
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
                counterSpinner: prevSpinner,
                loopAnimation: false,
                animationDuration: UIGradingView.animationDuration
            )
            self.delayAnimation(layer: newLayer, animation: animation, property: .transform, completion: { })
            
            /// Additionally set the "resting" transform.
            newLayer.transform = getInitialTransform(offset: offset, spinner: spinner, counterSpinner: prevSpinner)
            
            /// Prepare for next iteration.
            prevLayer = newLayer
            prevFrameSize = layerFrame.size
            prevSpinner = spinner
            
            circleLayers.append(shapeLayer)
        }
    }
    
    private func drawScoreBar() -> Void {
        let scoreSuperLayer = CALayer()
        layer.addSublayer(scoreSuperLayer)
        
        let scorePath = UIBezierPath()
        scorePath.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.9))
        scorePath.addLine(to: CGPoint(x: size.width * 0.9, y: size.height * 0.9))
        
        let scoreBackgroundLayer = CAShapeLayer()
        scoreBackgroundLayer.lineCap = .round
        scoreBackgroundLayer.lineWidth = 10
        scoreBackgroundLayer.strokeColor = UIColor.secondarySystemFill.cgColor
        scoreBackgroundLayer.path = scorePath.cgPath
        scoreSuperLayer.addSublayer(scoreBackgroundLayer)
        
        let scoreStrokeLayer = CAShapeLayer()
        scoreStrokeLayer.lineCap = .round
        scoreStrokeLayer.lineWidth = 10
        scoreStrokeLayer.strokeColor = UIColor.systemPink.cgColor
        scoreStrokeLayer.strokeEnd = 0.01
        scoreStrokeLayer.path = scorePath.cgPath
        scoreSuperLayer.addSublayer(scoreStrokeLayer)
        self.scoreStrokeLayer = scoreStrokeLayer
        
        sublayers.append(contentsOf: [scoreSuperLayer, scoreBackgroundLayer, scoreStrokeLayer])
    }
    
    func animateScore() -> Void {
        let sampleCount = 200
        
        let animation = CAKeyframeAnimation()
        var times: [NSNumber] = []
        var values: [Double] = []
        
        let distances = solution.distances(attempt: spinners, samples: sampleCount)
        
        for sampleNo in 0...sampleCount {
            let proportion: Double = Double(sampleNo) / Double(sampleCount)
            let score = Solution.score(upTo: sampleNo, of: distances)
            times.append(proportion as NSNumber)
            values.append(score)
        }
        
        animation.values = values
        animation.keyTimes = times
        animation.duration = UIGradingView.animationDuration
        
        let finalScore = Solution.score(upTo: distances.count, of: distances)
        self.delayAnimation(layer: scoreStrokeLayer, animation: animation, property: .strokeEnd, completion: { [weak self] in
            guard let self = self else { return }
            self.scoreStrokeLayer?.strokeEnd = finalScore
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + PuzzleView.transitionDuration + UIGradingView.animationDuration, execute: { [weak self] in
            if let self = self {
                let threshold = 0.9
                let state = finalScore > threshold
                self.gradingCompletionCallback(state)
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
