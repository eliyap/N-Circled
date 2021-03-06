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
    private weak var scoreTextLayer: CATextLayer? = nil
    
    private var gradingCompletionCallback: (Bool) -> Void
    
    private let scoreLabel: UILabel = .init()
    
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
        drawScoreText()
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
        var prevLayer: CALayer = layer
        var prevFrameSize: CGSize = size
        var prevSpinner: Spinner? = nil
        
        for index in spinners.indices {
            let spinner = spinners[index]
            
            let diameter: CGFloat = Spinner.baseRadius * spinner.amplitude
            let layerFrame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            
            /// Create layers.
            let gradientLayer = makeGradient(spinner: spinner)
            gradientLayer.frame = layerFrame
            
            let newLayer = CALayer()
            newLayer.frame = layerFrame
            
            let lineWidth: CGFloat = Spinner.lineWidth
            let path = CGMutablePath()
            path.addPath(makePath(diameter: diameter, lineWidth: lineWidth))
            
            /// Adds a thin radial line to make the axis of rotation obvious.
            let radialLine = UIBezierPath()
            radialLine.move(to: CGPoint(
                x: (diameter) / 2,
                y: (diameter) / 2
            ))
            radialLine.addLine(to: CGPoint(
                x: (diameter) / 2,
                y: .zero
            ))
            path.addPath(radialLine.cgPath)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = layerFrame
            shapeLayer.path = path
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
    
    private static let marginSize = 0.07
    private func drawScoreBar() -> Void {
        let scoreSuperLayer = CALayer()
        layer.addSublayer(scoreSuperLayer)
        
        let scorePath = UIBezierPath()
        let margin = size.width * Self.marginSize
        scorePath.move(to: CGPoint(x: 0 + margin, y: size.height - margin))
        scorePath.addLine(to: CGPoint(x: size.width - margin, y: size.height - margin))
        
        let scoreBackgroundLayer = CAShapeLayer()
        scoreBackgroundLayer.lineCap = .round
        scoreBackgroundLayer.lineWidth = 10
        scoreBackgroundLayer.strokeColor = UIColor.secondarySystemFill.cgColor
        scoreBackgroundLayer.path = scorePath.cgPath
        scoreSuperLayer.addSublayer(scoreBackgroundLayer)
        
        let scoreThresholdLayer = CAShapeLayer()
        scoreThresholdLayer.lineCap = .round
        scoreThresholdLayer.lineWidth = 10
        scoreThresholdLayer.strokeColor = UIColor.secondarySystemFill.cgColor
        scoreThresholdLayer.strokeEnd = Puzzle.scoreThreshold
        scoreThresholdLayer.path = scorePath.cgPath
        scoreSuperLayer.addSublayer(scoreThresholdLayer)
        
        let scoreStrokeLayer = CAShapeLayer()
        scoreStrokeLayer.lineCap = .round
        scoreStrokeLayer.lineWidth = 10
        scoreStrokeLayer.strokeColor = UIColor.systemPink.cgColor
        scoreStrokeLayer.strokeEnd = 0
        scoreStrokeLayer.path = scorePath.cgPath
        scoreSuperLayer.addSublayer(scoreStrokeLayer)
        self.scoreStrokeLayer = scoreStrokeLayer
        
        sublayers.append(contentsOf: [scoreSuperLayer, scoreBackgroundLayer, scoreThresholdLayer, scoreStrokeLayer])
    }
    
    func drawScoreText() -> Void {
        let textLayer = CATextLayer()
        textLayer.string = "Score: "
        textLayer.foregroundColor = UIColor.label.cgColor
        
        let fontSize: CGFloat = 24
        textLayer.frame = CGRect(
            origin: CGPoint(
                x: size.width * Self.marginSize,
                y: size.height * (1 - Self.marginSize) - fontSize
            ),
            size: CGSize(
                width: size.width,
                height: fontSize
            )
        )
        let fd = UIFont.systemFont(ofSize: fontSize * 2).fontDescriptor
        textLayer.font = UIFont(descriptor: fd.withDesign(.rounded) ?? fd, size: fontSize * 2)
        textLayer.fontSize = fontSize
        textLayer.contentsScale = UIScreen.main.scale
        
        self.scoreTextLayer = textLayer
        layer.addSublayer(textLayer)
        sublayers.append(textLayer)
    }
    
    /// Animate the scoring progress in the form of a filling bar,
    /// and a text label ticking up.
    /// Leave both at their final values on animation completion.
    func animateScore() -> Void {
        let sampleCount = 200
        
        let barAnim = CAKeyframeAnimation()
        let textAnim = CAKeyframeAnimation(keyPath: "string")
        var times: [NSNumber] = []
        var barValues: [Double] = []
        var textValues: [String] = []
        
        let distances = solution.distances(attempt: spinners, samples: sampleCount)
        
        for sampleNo in 0...sampleCount {
            let proportion: Double = Double(sampleNo) / Double(sampleCount)
            let score = Scorer.score(upTo: sampleNo, of: distances)
            times.append(proportion as NSNumber)
            barValues.append(score)
            textValues.append("Score: \(Int(score * 100)) / \(Int(Puzzle.scoreThreshold * 100))")
        }
        
        barAnim.values = barValues
        barAnim.keyTimes = times
        barAnim.duration = UIGradingView.animationDuration
        
        textAnim.values = textValues
        textAnim.keyTimes = times
        textAnim.duration = UIGradingView.animationDuration
        
        let finalScore = Scorer.score(upTo: distances.count, of: distances)
        self.delayAnimation(layer: scoreStrokeLayer, animation: barAnim, property: .strokeEnd, completion: { [weak self] in
            guard let self = self else { return }
            self.scoreStrokeLayer?.strokeEnd = finalScore
        })
        
        self.delayAnimation(layer: scoreTextLayer, animation: textAnim, property: .string, completion: { [weak self] in
            guard let self = self else { return }
            self.scoreTextLayer?.string = "Score: \(Int(finalScore * 100)) / \(Int(Puzzle.scoreThreshold * 100))"
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + PuzzleView.transitionDuration + UIGradingView.animationDuration, execute: { [weak self] in
            if let self = self {
                let state = finalScore > Puzzle.scoreThreshold
                self.gradingCompletionCallback(state)
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
