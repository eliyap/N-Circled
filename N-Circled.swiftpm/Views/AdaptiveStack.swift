//
//  AdaptiveStack.swift
//  
//  Source:
//  https://www.hackingwithswift.com/quick-start/swiftui/how-to-automatically-switch-between-hstack-and-vstack-based-on-size-class
//

import SwiftUI

struct AdaptiveStack<Content: View>: View {
    
    @Environment(\.verticalSizeClass) var sizeClass
    
    private let horizontalAlignment: HorizontalAlignment
    private let verticalAlignment: VerticalAlignment
    private let spacing: CGFloat?
    private let content: () -> Content

    init(horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        Group {
            if sizeClass == .compact {
                HStack(alignment: verticalAlignment, spacing: spacing, content: content)
            } else {
                VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
            }
        }
    }
}
