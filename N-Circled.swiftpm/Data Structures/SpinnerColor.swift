//
//  SpinnerColor.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 18/4/22.
//

import UIKit

public enum SpinnerColor: Int, CaseIterable {
    case blue
    case purple
    case red
    case yellow
    case green
    
    var cgColor: CGColor {
        switch self {
            case .green:
                return UIColor.SCGreen.cgColor
            case .yellow:
                return UIColor.SCYellow.cgColor
            case .red:
                return UIColor.SCRed.cgColor
            case .purple:
                return UIColor.SCPurple.cgColor
            case .blue:
                return UIColor.SCBlue.cgColor
        }
    }
}


extension UIColor {
    /// SC could be https://sixcolors.com/
    /// or Southern California, or SpinnerColor. Pick one.
    /// Permission obtained from Jason Snell via email.
    static let SCGreen = UIColor(named: "SC_Green")!
    static let SCYellow = UIColor(named: "SC_Yellow")!
    static let SCOrange = UIColor(named: "SC_Orange")!
    static let SCRed = UIColor(named: "SC_Red")!
    static let SCPurple = UIColor(named: "SC_Purple")!
    static let SCBlue = UIColor(named: "SC_Blue")!
}

let SCColors: [UIColor] = [
    .SCGreen,
    .SCYellow,
    .SCOrange,
    .SCRed,
    .SCPurple,
    .SCBlue,
]
