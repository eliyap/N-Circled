//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 5/4/22.
//

import Foundation

public struct Complex<Value: FloatingPoint> {
    let real: Value
    let imaginary: Value
    
    init(re: Value, im: Value) {
        self.real = re
        self.imaginary = im
    }
}

extension Complex {
    static func +(lhs: Self, rhs: Self) -> Self {
        return .init(re: lhs.real + rhs.real, im: lhs.imaginary + rhs.imaginary)
    }
    static func -(lhs: Self, rhs: Self) -> Self {
        return .init(re: lhs.real - rhs.real, im: lhs.imaginary - rhs.imaginary)
    }
}

extension Complex {
    var magnitude: Value {
        return sqrt(real * real + imaginary * imaginary)
    }
}
