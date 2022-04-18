import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: {
                    PuzzleView(solution: .Oval)
                }, label: {
                    Text("Puzzle 1 🥚")
                })
                NavigationLink(destination: {
                    PuzzleView(solution: .Star)
                }, label: {
                    Text("Puzzle 2 ⭐️")
                })
                NavigationLink(destination: {
                    PuzzleView(solution: .BowTie)
                }, label: {
                    Text("Puzzle 3 🎀")
                })
                NavigationLink(destination: {
                    PuzzleView(solution: .Heart)
                }, label: {
                    Text("Puzzle 4 ❤️")
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
                Text("\(spinnerHolder.spinnerSlots.count)")
                Button(action: {
                    withAnimation(.easeInOut(duration: PuzzleView.transitionDuration)) {
                        assert(spinnerHolder.gameState == .thinking, "Unexpected game state: \(spinnerHolder.gameState)")
                        spinnerHolder.gameState = .grading
                    }
                }, label: {
                    Text("Play!")
                })
            }
            GeometryReader { geo in
                if spinnerHolder.gameState == .thinking {
                    GradingView.init(size: geo.size, spinnerHolder: spinnerHolder, solution: solution)
                        .border(.red)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    CASpinner.init(size: geo.size, spinnerHolder: spinnerHolder, solution: solution)
                        .border(.purple)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            TwiddlerCollectionView(spinnerHolder: spinnerHolder)
                .frame(height: TwiddlerCollectionView.viewHeight)
        }
    }
}
