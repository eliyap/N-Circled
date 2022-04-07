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
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 64, y: 64, width: 160, height: 160), cornerRadius: 50).cgPath
        shapeLayer.fillColor = UIColor.red.cgColor
        
        let animation = CABasicAnimation(keyPath: "transform")

        animation.fromValue = CATransform3DMakeAffineTransform(CGAffineTransform.identity)
        animation.toValue = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: .pi))
        animation.duration = 1.25
        animation.autoreverses = false
        animation.repeatCount = .infinity
        
        shapeLayer.add(animation, property: .transform)

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
