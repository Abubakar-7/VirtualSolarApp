import Foundation
import FirebaseAuth

/// A class to manage and publish the user's authentication state across the app.
class AppState: ObservableObject {
    
    /// A published property indicating whether the user is currently logged in.
    /// - This uses FirebaseAuth to check if a user session exists.
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
}
