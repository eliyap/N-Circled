//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 6/4/22.
//

import SwiftUI

struct CASpinner: UIViewRepresentable {
    typealias UIViewType = CASpinnerView
    
    let size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    
    func makeUIView(context: Context) -> CASpinnerView {
        let view: UIViewType = .init(size: size)
        return view
    }
    
    func updateUIView(_ uiView: CASpinnerView, context: Context) {
        /// Nothing.
    }
}

final class CASpinnerView: UIView {
    
    private let spinners = [
        Spinner(amplitude: 0.5, frequency: +1, phase: .pi / 10),
        Spinner(amplitude: 0.4, frequency: +2, phase: .pi / 17),
        Spinner(amplitude: 0.3, frequency: +3, phase: .pi / 20),
        Spinner(amplitude: 0.2, frequency: +4, phase: .pi / 6),
        Spinner(amplitude: 0.1, frequency: +5, phase: .pi / 4),
    ]
    
    init(size: CGSize) {
        super.init(frame: .zero)
        
        let path = UIBezierPath()
        path.move(to: .zero)
        
        let baseRadius: CGFloat = 200
        
        for val in stride(from: 0.0, through: 1.0, by: 0.0001) {
            var offset: CGPoint = .zero
            for spinner in spinners {
                let spinnerOffset = spinner.offset(proportion: val)
                offset.x += spinnerOffset.y * baseRadius
                offset.y -= spinnerOffset.x * baseRadius
            }
            
//            offset.x *= -1
//            offset.y *= -1
            
            offset.x /= 2
            offset.y /= 2
            
            offset.x += size.width/2
            offset.y += size.height/2
            
            path.addLine(to: offset)
        }
        
        path.close()
        
        let sl = CAShapeLayer()
        sl.path = path.cgPath
        sl.fillColor = UIColor.purple.cgColor
        
        layer.addSublayer(sl)
        
        addSpinners(size: size)
    }
    
    private func addSpinners(size: CGSize) {
        let baseRadius: CGFloat = 200
        
        var prevLayer: CALayer = layer
        var prevFrameSize: CGSize = size
        var prevSpinner: Spinner? = nil
        
        for index in spinners.indices {
            let spinner = spinners[index]
            
            let diameter: CGFloat = baseRadius * spinner.amplitude
            let layerFrame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            
            /// Create layers.
            let gradientLayer = makeGradient()
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
            gradientLayer.mask = shapeLayer
            newLayer.addSublayer(gradientLayer)
            prevLayer.addSublayer(newLayer)
            
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

func makeGradient() -> CAGradientLayer {
    let gl = CAGradientLayer()
    gl.startPoint = CGPoint(x: 0.5, y: 0.5)
    gl.endPoint = CGPoint(x: 0.5, y: 0)
    gl.type = .conic
    gl.colors = [
        UIColor.clear.cgColor,
        UIColor.label.cgColor,
    ]
    
    return gl
}
