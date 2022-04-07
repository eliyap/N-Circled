//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 6/4/22.
//

import SwiftUI

struct CASpinner: UIViewRepresentable {
    typealias UIViewType = CASpinnerView
    
    func makeUIView(context: Context) -> CASpinnerView {
        let view: UIViewType = .init()
        return view
    }
    
    func updateUIView(_ uiView: CASpinnerView, context: Context) {
        /// Nothing.
    }
    
    
    
}

final class CASpinnerView: UIView {
    init() {
        super.init(frame: .zero)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: 64, y: 64, width: 160, height: 160), cornerRadius: 50).cgPath
        shapeLayer.fillColor = UIColor.red.cgColor
        
        let animation = CABasicAnimation(keyPath: "transform")

        var transform = CATransform3DIdentity
        transform.m34 = -0.002

        animation.toValue = CATransform3DRotate(transform, CGFloat(90 * Double.pi / 180.0), 0, 1, 0)
        animation.duration = 1.25

        shapeLayer.add(animation, property: .transform)
        
        layer.addSublayer(shapeLayer)
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
