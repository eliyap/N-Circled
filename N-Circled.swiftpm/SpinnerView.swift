//
//  File.swift
//  N-Circled
//
//  Created by Secret Asian Man Dev on 5/4/22.
//

import SwiftUI

struct SpinnerView: View {
    
    public let dftResults: [Complex<Float>] = test()
    
    private let spinners: [Spinner] = [
        .init(amplitude: 0.25, frequency: 1, phase: .zero),
        .init(amplitude: 0.50, frequency: 2, phase: .zero),
        .init(amplitude: 0.75, frequency: 3, phase: .zero),
        .init(amplitude: 1.00, frequency: 4, phase: .zero),
    ]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { (context, size) in
                let location = dftResults.fourierSeriesResult(date: timeline.date, size: size)
                context.draw(Image(systemName: "heart"), at: location)
                
                var offset: CGPoint = .zero
                for spinner in spinners {
                    spinner.draw(in: &context, date: timeline.date, size: size, offset: offset)
//                    offset.x += spinner.offset(at: timeline.date).x * min(size.height, size.height)
//                    offset.y += spinner.offset(at: timeline.date).y * min(size.height, size.height)
                }
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(spinners) { spinner in
                        Canvas { (context, size) in
                            spinner.draw(in: &context, date: timeline.date, size: size, offset: .zero)
                        }
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
                .frame(height: 100)
        }
    }
}

extension Collection where Element == Complex<Float> {
    func fourierSeriesResult(date: Date, size: CGSize) -> CGPoint {
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        for (idx, value) in self.enumerated() {
            /// Scale time by idx (i.e. discrete frequency).
            let angle = date.timeIntervalSince1970 * TimeInterval(idx)
            
            x += CGFloat(cos(angle)) * CGFloat(value.magnitude)
            y += CGFloat(sin(angle)) * CGFloat(value.magnitude)
        }

        x = x / CGFloat(self.count)
        y = y / CGFloat(self.count)

        /// Scale to shorter side.
        let scale = Swift.min(size.width, size.height)
        return CGPoint(
            x: x * scale / 2 + size.width / 2,
            y: y * scale / 2 + size.height / 2
        )
    }
}

