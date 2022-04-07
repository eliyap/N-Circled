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
        
        print(size)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.type = .conic
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.green.cgColor]
        gradientLayer.frame = .init(origin: .zero, size: size)
        layer.addSublayer(gradientLayer)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = makePath(diameter: 100, frameSize: size)
        shapeLayer.lineWidth = 5
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = nil
        
        let animation = makeAnimation()
        
        gradientLayer.add(animation, property: .transform)
        gradientLayer.mask = shapeLayer
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
    }
    
    func add(_ animation: CAAnimation, property: AnimatableProperty) -> Void {
        self.add(animation, forKey: property.rawValue)
    }
}

func makePath(diameter: CGFloat, frameSize: CGSize) -> CGPath {
    /// Center square at frame center.
    let rect = CGRect(
        x: -diameter/2 + frameSize.width/2,
        y: -diameter/2 + frameSize.height/2,
        width: diameter,
        height: diameter
    )
    return UIBezierPath(roundedRect: rect, cornerRadius: diameter/2).cgPath
}

func makeAnimation() -> CAAnimation {
    let animation = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.transform.rawValue)

    var transforms: [CATransform3D] = []
    var keyTimes: [NSNumber] = []
    
    /// Move by quarters, as if we go by halves the rotation will be back and forth.
    /// Thirds might be possible, but could introduce floating point errors.
    for val in stride(from: 0, through: 1, by: 0.25) {
        let transform = CGAffineTransform(rotationAngle: val * 2 * .pi)
        transforms.append(CATransform3DMakeAffineTransform(transform))
        keyTimes.append(val as NSNumber)
    }
    animation.values = transforms
    animation.keyTimes = keyTimes
    animation.duration = 1.25
    animation.autoreverses = false
    animation.repeatCount = .infinity
    
    return animation
}
