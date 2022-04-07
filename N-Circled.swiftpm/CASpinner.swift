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
        
        let sideLength = min(size.width, size.height)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = makePath(diameter: 50, frameSize: size)
        shapeLayer.fillColor = UIColor.red.cgColor
        print("sap", shapeLayer.anchorPoint)
        
        let animation = CAKeyframeAnimation(keyPath: "transform")

        var transforms: [CATransform3D] = []
        var keyTimes: [NSNumber] = []
        
        /// Move by quarters, as if we go by halves the rotation will be back and forth.
        /// Thirds might be possible, but could introduce floating point errors.
        for val in stride(from: 0, through: 1, by: 0.25) {
            var transform = CGAffineTransform.identity
            transform = transform.rotated(by: val * 2 * .pi)
//            transform = transform.translatedBy(x: -sideLength / 2, y: -sideLength / 2)
            
            transforms.append(CATransform3DMakeAffineTransform(transform))
            keyTimes.append(val as NSNumber)
        }
        animation.values = transforms
        animation.keyTimes = keyTimes
        animation.duration = 1.25
        animation.autoreverses = false
        animation.repeatCount = .infinity
        
        gradientLayer.add(animation, property: .transform)
//        shapeLayer.add(animation, property: .transform)

        gradientLayer.mask = shapeLayer
//        layer.addSublayer(shapeLayer)
        
        print("sap", shapeLayer.anchorPoint)
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
