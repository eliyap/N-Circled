//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 14/4/22.
//

import UIKit

extension CALayer {
    /// A safer view into `CALayer`'s string-ly typed keys.
    /// A complete list: https://stackoverflow.com/questions/44230796/what-is-the-full-keypath-list-for-cabasicanimation
    enum AnimatableProperty: String {
        case transform
        case sublayerTransform
        case strokeStart
        case strokeEnd
        
        /// For `CATextLayer`.
        case string
    }
    
    func add(_ animation: CAAnimation, property: AnimatableProperty) -> Void {
        /// `async` solves an issue where embedding in `NavigationView` stops the animation on appearance.
        /// Source: https://developer.apple.com/forums/thread/682779
        DispatchQueue.main.async { [weak self] in
            self?.add(animation, forKey: property.rawValue)
        }
    }
}
