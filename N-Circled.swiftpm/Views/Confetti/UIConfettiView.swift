//
//  Adapted from https://github.com/ugurethemaydin/SwiftConfettiView
//  MIT License
//  
//  Copyright (c) 2019 Uğur Ethem AYDIN
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  
//  Created by Uğur Ethem AYDIN on 2019
//

import UIKit
import QuartzCore

public class UIConfettiView: UIView {

    public enum ConfettiType: String {
        case confetti
        case triangle
        case star
        case diamond
    }

    public var size: CGSize = .zero
    
    private let emitter: CAEmitterLayer = .init()
    public let colors: [UIColor] = [
        UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
        UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
        UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
        UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
        UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0),
    ]
    private let intensity: Float = 0.5
    private let type: ConfettiType = .confetti
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Create a strong, short "burst" of confetti to simulate a celebratory explosion.
    public func burstConfetti() {
        let burstDuration: TimeInterval = 0.3
        let intensityMultiplier: Float = 5.0
        
        let cells: [CAEmitterCell] = colors.map { color in
            UIConfettiView.confettiWithColor(color: color, intensity: self.intensity * intensityMultiplier, type: self.type)
        }
        let lifetime = TimeInterval(cells[0].lifetime)
        
        let burstLayer: CAEmitterLayer = .init()
        burstLayer.emitterPosition = CGPoint(x: size.width / 2.0, y: 0)
        burstLayer.emitterShape = CAEmitterLayerEmitterShape.line
        burstLayer.emitterSize = CGSize(width: size.width, height: 1)
        burstLayer.emitterCells = cells
        layer.addSublayer(burstLayer)
        
        /// Stop emission after a short time.
        DispatchQueue.main.asyncAfter(deadline: .now() + burstDuration, execute: { [weak burstLayer] in
            burstLayer?.birthRate = 0
        })
        
        /// Remove layer when all particles reach end of life.
        DispatchQueue.main.asyncAfter(deadline: .now() + burstDuration + lifetime, execute: { [weak burstLayer] in
            burstLayer?.removeFromSuperlayer()
        })
    }

    public func startConfetti() {
        emitter.emitterPosition = CGPoint(x: size.width / 2.0, y: 0)
        emitter.emitterShape = CAEmitterLayerEmitterShape.line
        emitter.emitterSize = CGSize(width: size.width, height: 1)

        var cells = [CAEmitterCell]()
        for color in colors {
            cells.append(UIConfettiView.confettiWithColor(color: color, intensity: self.intensity, type: self.type))
        }

        emitter.emitterCells = cells
        layer.addSublayer(emitter)
    }

    public func stopConfetti() {
        emitter.birthRate = 0
    }

    private static func confettiWithColor(color: UIColor, intensity: Float, type: ConfettiType) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        confetti.birthRate = 6.0 * intensity
        confetti.lifetime = 14.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(350.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat(Double.pi)
        confetti.emissionRange = CGFloat(Double.pi)
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        confetti.scaleRange = 0.5
        confetti.scaleSpeed = -0.05
        
        if let image = UIImage(named: type.rawValue) {
            confetti.contents = image.cgImage
        } else {
            assert(false, "No image with name: \(type.rawValue)")
        }
        
        return confetti
    }
}
