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
    public let solution: Solution
    
    func makeUIView(context: Context) -> CASpinnerView {
        let view: UIViewType = .init(size: size, spinnerHolder: spinnerHolder, solution: solution)
        return view
    }
    
    func updateUIView(_ uiView: CASpinnerView, context: Context) {
        /// Nothing.
    }
}

final class CASpinnerView: UIView {
    
    public static let animationDuration: TimeInterval = 4.0
    
    /// Solution to the current puzzle.
    private let solution: Solution
    
    private let previewView: SpinnerPreviewView
    
    private var observers: Set<AnyCancellable> = []
    
    init(size: CGSize, spinnerHolder: SpinnerHolder, solution: Solution) {
        self.solution = solution
        self.previewView = .init(size: size, spinnerHolder: spinnerHolder, solution: solution)
        super.init(frame: .zero)
        
        let gradingObserver = spinnerHolder.$isGrading
            .sink(receiveValue: { [weak self] isGrading in
                guard let self = self else { return }
                if isGrading {
                    let animation = CABasicAnimation(keyPath: CALayer.AnimatableProperty.transform.rawValue)
                    
                    let fromTransform = CGAffineTransform(scaleX: 1, y: 1)
                        .concatenating(CGAffineTransform(translationX: 0, y: 0))
                    animation.fromValue = CATransform3DMakeAffineTransform(fromTransform)
                    
                    let toTransform = CGAffineTransform(scaleX: 0, y: 0)
                        .concatenating(CGAffineTransform(translationX: size.width / 2, y: size.height / 2))
                    animation.toValue = CATransform3DMakeAffineTransform(toTransform)
                    animation.duration = 5
                    self.previewView.layer.add(animation, property: .transform)
                } else {
                    #warning("TODO")
                }
            })
        gradingObserver.store(in: &observers)
        
        addSubview(previewView)
        
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
    animation.duration = CASpinnerView.animationDuration
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
