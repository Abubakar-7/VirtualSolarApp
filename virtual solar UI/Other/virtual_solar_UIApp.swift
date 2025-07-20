import SwiftUI
import Firebase
import FacebookCore
import FirebaseAuth
import FirebaseAppCheck

/// The main entry point for the Virtual Solar UI application.
@main
struct virtual_solar_UIApp: App {
    
    /// Connects the custom AppDelegate class to handle application lifecycle events.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    /// Shared app-wide state object to track user authentication status.
    @StateObject var appState = AppState()

    /// Initializes Firebase and forcibly signs out any existing user session on launch.
    init() {
        // Configure Firebase during app initialization.
        FirebaseApp.configure()

        // Force sign out any previously authenticated user.
        do {
            try Auth.auth().signOut()
            print("🔒 User forcibly signed out on launch.")
        } catch {
            print("❌ Sign-out failed: \(error.localizedDescription)")
        }
    }

    /// Defines the main scene and initial view based on authentication state.
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                // If the user is logged in, show the main navigation UI.
                NavigationBar()
                    .environmentObject(appState)
            } else {
                // If not logged in, show the content/login view.
                ContentView()
                    .environmentObject(appState)
            }
        }
    }
}
