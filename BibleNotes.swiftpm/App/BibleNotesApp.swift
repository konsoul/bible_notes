import SwiftUI

@main
struct BibleNotesApp: App {
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if appViewModel.showSplashScreen {
                    SplashScreenView()
                        .environmentObject(appViewModel)
                        .transition(.opacity)
                } else {
                    ReaderView()
                        .environmentObject(appViewModel)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
