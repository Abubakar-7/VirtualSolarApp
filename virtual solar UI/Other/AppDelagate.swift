import UIKit
import Firebase
import FacebookCore
import FirebaseAppCheck

/// AppDelegate handles global app lifecycle events including Firebase and Facebook SDK setup.
class AppDelegate: NSObject, UIApplicationDelegate {

    /// Called when the application has finished launching.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        // MARK: - Firebase App Check Setup (Only in Debug Builds)

        #if DEBUG
        // Use the AppCheck debug provider to simulate App Check during development.
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #endif

        // MARK: - Firebase Configuration

        // Initialize Firebase only if it's not already configured.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        print("✅ App Check Debug Mode setup done. Awaiting token...")

        // MARK: - Facebook SDK Initialization

        // Initialize Facebook SDK for login support.
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        return true
    }

    /// Called when the app is asked to open a URL (e.g., for handling Facebook login redirection).
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Delegate the handling of URL to the Facebook SDK.
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
}
