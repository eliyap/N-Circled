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
    init(size: CGSize) {
        super.init(frame: .zero)
        
        let baseRadius: CGFloat = 200
        
        let spinners = [
            Spinner(amplitude: 1.00, frequency: +1, phase: .pi / 2),
            Spinner(amplitude: 0.50, frequency: -1, phase: .pi / 2),
            Spinner(amplitude: 0.25, frequency: +3, phase: .pi / 2),
        ]
        
        var prevLayer: CALayer = layer
        var prevFrameSize: CGSize = size
        
        for index in spinners.indices {
            let spinner = spinners[index]
            
            let diameter: CGFloat = baseRadius * spinner.amplitude
            let layerFrame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            
            /// Create layers.
            let gradientLayer = makeGradient()
            gradientLayer.frame = layerFrame
            
            let newLayer = CALayer()
            newLayer.frame = layerFrame
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.frame = layerFrame
            shapeLayer.path = makePath(diameter: diameter)
            shapeLayer.fillColor = nil
            shapeLayer.strokeColor = UIColor.black.cgColor
            shapeLayer.lineWidth = 2
            
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
            let animation = makeAnimation(offset: offset, spinner: spinner)
            newLayer.add(animation, property: .transform)
            
            /// Prepare for next iteration.
            prevLayer = newLayer
            prevFrameSize = layerFrame.size
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

func makePath(diameter: CGFloat) -> CGPath {
    /// Center square at frame center.
    let rect = CGRect(
        x: 0,
        y: 0,
        width: diameter,
        height: diameter
    )
    return UIBezierPath(roundedRect: rect, cornerRadius: diameter/2).cgPath
}

func x() {
    
}

func makeAnimation(offset: CGPoint, spinner: Spinner) -> CAAnimation {
    let animation = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.transform.rawValue)

    var transforms: [CATransform3D] = []
    var keyTimes: [NSNumber] = []
    
    /// Due to `CoreAnimation`'s high performance, we can afford many keyframes.
    /// A higher number mitigates issues arising from the "shortest rotation" behaviour in `CATransform`s.
    for val in stride(from: 0, through: 1, by: 0.025) {
        let radians = (val * 2 * .pi * Double(spinner.frequency)) + spinner.phase
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
