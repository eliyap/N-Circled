import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: {
                    PuzzleView(solution: .Oval)
                }, label: {
                    Text("Puzzle 1")
                })
                NavigationLink(destination: {
                    PuzzleView(solution: .Oval)
                }, label: {
                    Text("Puzzle 2")
                })
                NavigationLink(destination: {
                    PuzzleView(solution: .Oval)
                }, label: {
                    Text("Puzzle 3")
                })   
            }
        }
    }
}

struct PuzzleView: View {
    
    public let solution: Solution
    @StateObject private var spinnerHolder: SpinnerHolder = .init()
    
    public static let transitionDuration: TimeInterval = 0.5
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, WWDC!")
                Text("\(spinnerHolder.spinners.count)")
                Button(action: {
                    withAnimation(.easeInOut(duration: PuzzleView.transitionDuration)) {
                        spinnerHolder.isGrading.toggle()
                    }
                }, label: {
                    Text("Play!")
                })
            }
            GeometryReader { geo in
                if spinnerHolder.isGrading {
                    GradingView.init(size: geo.size, spinnerHolder: spinnerHolder, solution: solution)
                        .border(.red)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    CASpinner.init(size: geo.size, spinnerHolder: spinnerHolder, solution: solution)
                        .border(.purple)
                        .transition(.opacity.combined(with: .scale))
                }
            }
                /// Custom sizing fixes issue where view below was not factored into `GeometryReader`'s `size` on first appearance.
                .aspectRatio(1, contentMode: .fit)
                .frame(maxHeight: .infinity)
            TwiddlerCollectionView(spinnerHolder: spinnerHolder)
                .frame(height: TwiddlerCollectionView.viewHeight)
        }
    }
}
