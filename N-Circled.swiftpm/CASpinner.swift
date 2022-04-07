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
        
        let d1: CGFloat = 100
        let sl1 = CAShapeLayer()
        sl1.path = makePath(diameter: d1, frameSize: .zero)
        sl1.borderColor = UIColor.green.cgColor
        sl1.borderWidth = 2
        sl1.frame = CGRect(x: 0, y: 0, width: d1, height: d1)
        sl1.fillColor = UIColor.green.cgColor
        sl1.add(makeAnimation(), property: .transform)
        
        let d2: CGFloat = 50
        let sl2 = CAShapeLayer()
        sl2.path = makePath(diameter: d2, frameSize: .zero)
        sl2.borderColor = UIColor.red.cgColor
        sl2.borderWidth = 2
        sl2.frame = CGRect(x: 0, y: 0, width: d2, height: d2)
        sl2.fillColor = UIColor.red.cgColor
        sl2.add(makeAnimation(), property: .transform)
        
        let d3: CGFloat = 25
        let sl3 = CAShapeLayer()
        sl3.path = makePath(diameter: d3, frameSize: .zero)
        sl3.borderColor = UIColor.purple.cgColor
        sl3.borderWidth = 2
        sl3.frame = CGRect(x: 0, y: 0, width: d3, height: d3)
        sl3.fillColor = UIColor.purple.cgColor
        sl3.add(makeAnimation(), property: .transform)
            
        layer.addSublayer(sl1)
        layer.sublayerTransform = CATransform3DMakeAffineTransform(CGAffineTransform(
            translationX: size.width/2 - d1/2,
            y: size.height/2 - d1/2
        ))
        
        sl1.addSublayer(sl2)
        sl1.sublayerTransform = CATransform3DMakeAffineTransform(CGAffineTransform(
            translationX: d1/2 - d2/2,
            y: -d2/2
        ))
        
        sl2.addSublayer(sl3)
        sl2.sublayerTransform = CATransform3DMakeAffineTransform(CGAffineTransform(
            translationX: d2/2 - d3/2,
            y: -d3/2
        ))
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

func makeSublayerAnimation(size: CGSize) -> CAAnimation {
    let animation = CAKeyframeAnimation(keyPath: CALayer.AnimatableProperty.sublayerTransform.rawValue)

    var transforms: [CATransform3D] = []
    var keyTimes: [NSNumber] = []
    
    /// Move by quarters, as if we go by halves the rotation will be back and forth.
    /// Thirds might be possible, but could introduce floating point errors.
    for val in stride(from: 0, through: 1, by: 0.3333) {
        let transform = CGAffineTransform(translationX: 100, y: 0)
            .rotated(by: val * 2 * .pi)
//            .concatenating(
//                CGAffineTransform(rotationAngle: val * 2 * .pi)
//                    .translatedBy(x: 50, y: 50)
//                CGAffineTransform(translationX: -50, y: -50)
//                    .rotated(by: val * 2 * .pi)
//            )
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
