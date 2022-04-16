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
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, WWDC!")
                Text("\(spinnerHolder.spinners.count)")
                Button(action: {
                    spinnerHolder.isGrading = true
                }, label: {
                    Text("Play!")
                })
            }
            GeometryReader { geo in
                CASpinner.init(size: geo.size, spinnerHolder: spinnerHolder, solution: solution)
            }
                .border(Color.red)
            TwiddlerCollectionView(spinnerHolder: spinnerHolder)
                .frame(height: TwiddlerCollectionView.viewHeight)
        }
    }
}
