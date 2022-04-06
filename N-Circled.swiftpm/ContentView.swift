import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, WWDC!")
            DoodleView()
                .border(Color.red)
                .onAppear(perform: {
                    test()
                })
            SpinnerView()
        }
    }
}
