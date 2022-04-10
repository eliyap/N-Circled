import SwiftUI

struct ContentView: View {
    
    @StateObject private var spinnerHolder: SpinnerHolder = .init()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, WWDC!")
            Text("\(spinnerHolder.spinners.count)")
            GeometryReader { geo in
                CASpinner.init(size: geo.size, spinnerHolder: spinnerHolder)
            }
                .border(Color.red)
            TwiddlerCollectionView(spinnerHolder: spinnerHolder)
                .frame(height: TwiddlerCollectionView.viewHeight)
        }
    }
}
