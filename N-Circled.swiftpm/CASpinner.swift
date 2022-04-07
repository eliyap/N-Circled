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
        
        let d1: CGFloat = 200
        
        let gl1 = CAGradientLayer()
        gl1.startPoint = CGPoint(x: 0.5, y: 0.5)
        gl1.endPoint = CGPoint(x: 0.5, y: 0)
        gl1.type = .conic
        gl1.colors = [
            UIColor.clear.cgColor,
            UIColor.label.cgColor,
        ]
        gl1.frame = CGRect(x: 0, y: 0, width: d1, height: d1)
        
        let l1 = CALayer()
        l1.frame = CGRect(x: 0, y: 0, width: d1, height: d1)
        layer.addSublayer(l1)
        l1.addSublayer(gl1)
        
        let sl1 = CAShapeLayer()
        sl1.path = makePath(diameter: d1, frameSize: .zero)
        sl1.fillColor = nil
        sl1.strokeColor = UIColor.black.cgColor
        sl1.lineWidth = 2
        sl1.frame = CGRect(x: 0, y: 0, width: d1, height: d1)
        gl1.mask = sl1
        let a1 = makeAnimation(offset: CGPoint(
            x: size.width/2 - d1/2,
            y: size.height/2 - d1/2
        ))
        l1.add(a1, property: .transform)
        
        //

        let d2: CGFloat = 100
        
        let gl2 = CAGradientLayer()
        gl2.startPoint = CGPoint(x: 0.5, y: 0.5)
        gl2.endPoint = CGPoint(x: 0.5, y: 0)
        gl2.type = .conic
        gl2.colors = [
            UIColor.clear.cgColor,
            UIColor.label.cgColor,
        ]
        gl2.frame = CGRect(x: 0, y: 0, width: d2, height: d2)

        let l2 = CALayer()
        l2.frame = CGRect(x: 0, y: 0, width: d2, height: d2)
        layer.addSublayer(l2)
        l2.addSublayer(gl2)

        let sl2 = CAShapeLayer()
        sl2.path = makePath(diameter: d2, frameSize: .zero)
        sl2.fillColor = nil
        sl2.strokeColor = UIColor.black.cgColor
        sl2.lineWidth = 2
        sl2.frame = CGRect(x: 0, y: 0, width: d2, height: d2)
        gl2.mask = sl2
        let a2 = makeAnimation(offset: CGPoint(
            x: d1/2 - d2/2,
            y: -d2/2
        ))
        l2.add(a2, property: .transform)
        
        //

        let d3: CGFloat = 50
        
        let gl3 = CAGradientLayer()
        gl3.startPoint = CGPoint(x: 0.5, y: 0.5)
        gl3.endPoint = CGPoint(x: 0.5, y: 0)
        gl3.type = .conic
        gl3.colors = [
            UIColor.clear.cgColor,
            UIColor.label.cgColor,
        ]
        gl3.frame = CGRect(x: 0, y: 0, width: d3, height: d3)

        let l3 = CALayer()
        l3.frame = CGRect(x: 0, y: 0, width: d3, height: d3)
        layer.addSublayer(l3)
        l3.addSublayer(gl3)

        let sl3 = CAShapeLayer()
        sl3.path = makePath(diameter: d3, frameSize: .zero)
        sl3.fillColor = nil
        sl3.strokeColor = UIColor.black.cgColor
        sl3.lineWidth = 2
        sl3.frame = CGRect(x: 0, y: 0, width: d3, height: d3)
        gl3.mask = sl3
        let a3 = makeAnimation(offset: CGPoint(
            x: d2/2 - d3/2,
            y: -d3/2
        ))
        l3.add(a3, property: .transform)
        
        l1.addSublayer(l2)
        
        l2.addSublayer(l3)
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

func makePath(diameter: CGFloat, frameSize: CGSize) -> CGPath {
    /// Center square at frame center.
    let rect = CGRect(
        x: 0,
        y: 0,
        width: diameter,
        height: diameter
    )
    return UIBezierPath(roundedRect: rect, cornerRadius: diameter/2).cgPath
}

func makeAnimation(offset: CGPoint) -> CAAnimation {
    let animation = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.transform.rawValue)

    var transforms: [CATransform3D] = []
    var keyTimes: [NSNumber] = []
    
    /// Move by quarters, as if we go by halves the rotation will be back and forth.
    /// Thirds might be possible, but could introduce floating point errors.
    for val in stride(from: 0, through: 1, by: 0.25) {
        let transform = CGAffineTransform(rotationAngle: val * 2 * .pi)
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
