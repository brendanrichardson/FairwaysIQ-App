import SwiftUI

@main
struct FairwayIQApp: App {
    @StateObject private var bagStore = BagStore()
    @StateObject private var locationProvider = LocationProvider()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bagStore)
                .environmentObject(locationProvider)
        }
    }
}
