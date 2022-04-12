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
    
    func makeUIView(context: Context) -> CASpinnerView {
        let view: UIViewType = .init(size: size, spinnerHolder: spinnerHolder)
        return view
    }
    
    func updateUIView(_ uiView: CASpinnerView, context: Context) {
        /// Nothing.
    }
}

final class CASpinnerView: UIView {
    
    private var spinners: [Spinner] = []
    private var layers: [CAShapeLayer] = []
    
    private var observers: Set<AnyCancellable> = []
    
    private let size: CGSize
    
    /// Composed IDFT sublayers.
    let strokeStartLayer: CAShapeLayer
    let strokeEndLayer: CAShapeLayer
    
    init(size: CGSize, spinnerHolder: SpinnerHolder) {
        self.size = size
        self.strokeStartLayer = .init()
        self.strokeEndLayer = .init()
        super.init(frame: .zero)
        
        layer.addSublayer(strokeStartLayer)
        layer.addSublayer(strokeEndLayer)
        
        addShape(size: size)
        addSpinners(size: size)
        
        let spinnersObserver = spinnerHolder.$spinners
            .sink(receiveValue: { [weak self] spinners in
                self?.spinners = spinners
                self?.layers = []
                self?.redrawSpinners()
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
    
    private func redrawSpinners() {
        for sublayer in layer.sublayers ?? [] {
            sublayer.removeFromSuperlayer()
        }
        print(frame.size)
        addShape(size: size)
        addSpinners(size: size)
    }
    
    private func addShape(size: CGSize) -> Void {
        let path = UIBezierPath()
        let baseRadius: CGFloat = 200
        
        func point(at proportion: CGFloat) -> CGPoint {
            var offset: CGPoint = .zero
            for spinner in spinners {
                let spinnerOffset = spinner.unitOffset(proportion: proportion)
                offset.x += spinnerOffset.x * baseRadius
                offset.y += spinnerOffset.y * baseRadius
            }
            
            /// Rotate point 90 degrees.
            (offset.x, offset.y) = (offset.y, -offset.x)
            
            /// Apply scaling and offset.
            offset.x /= 2
            offset.y /= 2
            offset.x += size.width/2
            offset.y += size.height/2
            
            assert(!offset.x.isNaN)
            assert(!offset.y.isNaN)
            
            return offset
        }
        
        path.move(to: point(at: .zero))
        for val in stride(from: 0.0, through: 1.0, by: 0.0001) {
            path.addLine(to: point(at: val))
        }
        path.close()
        
        strokeStartLayer.path = path.cgPath
        strokeStartLayer.strokeColor = UIColor.systemTeal.cgColor
        strokeStartLayer.fillColor = nil
        strokeStartLayer.lineWidth = 3
        
        sl.add(makeStrokeAnimation(spinners: spinners), property: .strokeEnd)
        
        layer.addSublayer(strokeStartLayer)
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

extension CALayer {
    /// A safer view into `CALayer`'s string-ly typed keys.
    /// A complete list: https://stackoverflow.com/questions/44230796/what-is-the-full-keypath-list-for-cabasicanimation
    enum AnimatableProperty: String {
        case transform
        case sublayerTransform
        case strokeStart
        case strokeEnd
    }
    
    func add(_ animation: CAAnimation, property: AnimatableProperty) -> Void {
        self.add(animation, forKey: property.rawValue)
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
    animation.duration = 4
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

func makeStrokeAnimation(spinners: [Spinner]) -> CAAnimation {
    
    let animation = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.strokeEnd.rawValue)

    var values: [CGFloat] = []
    var keyTimes: [NSNumber] = []

    /// Due to `CoreAnimation`'s high performance, we can afford many keyframes.
    let numSamples = 1000
    
    /// Estimated Cumulative Length.
    var ecl: Double = .zero
    
    for sampleNo in 0..<numSamples {
        let proportion = CGFloat(sampleNo) / CGFloat(numSamples)
        
        /// Leverage the fact that velocity is always perpendicular to offset.
        let estVel = spinners.velocityFor(proportion: proportion)
        
        ecl += sqrt(estVel.squaredDistance(to: .zero))
        values.append(ecl)
        
        keyTimes.append(proportion as NSNumber)
    }
    
    /// Normalize all samples.
    for sampleNo in 0..<numSamples {
        values[sampleNo] /= ecl
    }
    
    animation.values = values
    animation.keyTimes = keyTimes
    animation.duration = 4
    animation.autoreverses = false
    animation.repeatCount = .infinity

    return animation
}

func interpolateIdftLength(
    spinners: [Spinner],
    numSamples: Int = 1000
) -> [(length: CGFloat, time: NSNumber)] {
    
    var result: [(CGFloat, NSNumber)] = []
    
    /// Estimated Cumulative Length.
    var ecl: CGFloat = .zero
    
    for sampleNo in 0..<numSamples {
        let proportion = CGFloat(sampleNo) / CGFloat(numSamples)
        let estVel = spinners.velocityFor(proportion: proportion)
        ecl += sqrt(estVel.squaredDistance(to: .zero))
        result.append((
            length: ecl,
            time: proportion as NSNumber
        ))
    }
    
    /// Normalize lengths.
    for sampleNo in 0..<numSamples {
        result[sampleNo].0 /= ecl
    }
    
    return result
}

