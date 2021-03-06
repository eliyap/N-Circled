//
//  SpinnerColor.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 18/4/22.
//

import UIKit

/// A simplified color representation to allow easy `Hashable`, `Codable`,
/// etc. conformance.
public enum SpinnerColor: Int, CaseIterable {
    
    case blue
    case purple
    case red
    /// `orange` omitted for being confusingly similar.
    case yellow
    case green
    
    var uiColor: UIColor {
        switch self {
            case .green:
                return UIColor.SCGreen
            case .yellow:
                return UIColor.SCYellow
            case .red:
                return UIColor.SCRed
            case .purple:
                return UIColor.SCPurple
            case .blue:
                return UIColor.SCBlue
        }
    }
}

extension SpinnerColor: Codable { /** Automatically synthesized. **/ }

extension SpinnerColor: Equatable { /** Automatically synthesized. **/ }

extension SpinnerColor: Hashable { /** Automatically synthesized. **/ }

extension UIColor {
    /// SC could be https://sixcolors.com/
    /// or Southern California, or SpinnerColor. Who knows?
    /// Permission obtained from Jason Snell via email.
    static let SCGreen = UIColor(named: "SC_Green")!
    static let SCYellow = UIColor(named: "SC_Yellow")!
    static let SCOrange = UIColor(named: "SC_Orange")!
    static let SCRed = UIColor(named: "SC_Red")!
    static let SCPurple = UIColor(named: "SC_Purple")!
    static let SCBlue = UIColor(named: "SC_Blue")!
}
