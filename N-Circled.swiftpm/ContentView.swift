import SwiftUI

struct ContentView: View {
    
    var body: some View {
        PuzzleView()
    }
}

struct PuzzleView: View {
    
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
                    #warning("TODO")
                    print("play...")
                }, label: {
                    Text("Play!")
                })
            }
            GeometryReader { geo in
                CASpinner.init(size: geo.size, spinnerHolder: spinnerHolder)
            }
                .border(Color.red)
            TwiddlerCollectionView(spinnerHolder: spinnerHolder)
                .frame(height: TwiddlerCollectionView.viewHeight)
        }
    }
}
