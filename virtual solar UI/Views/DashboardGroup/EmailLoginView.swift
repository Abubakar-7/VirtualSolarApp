import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// View that allows users to log in with their email and password.
/// On successful login, checks whether 2FA has been completed.
struct EmailLoginView: View {
    
    // MARK: - User Input
    @State private var email = ""
    @State private var password = ""

    // MARK: - Error States
    @State private var wrongUsername = 0
    @State private var wrongPassword = 0

    // MARK: - Navigation
    @State private var is2FADone = false
    @State private var navigateToProfileSetup = false

    // MARK: - Environment
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    // MARK: - Focus States
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()

                VStack {
                    // MARK: - Logo and Title
                    Image("SolarCloudLogo")
                    Image("SolarCloudName")

                    Text("Login")
                        .font(Font.custom("Poppins", size: 40))
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 100)

                    // MARK: - Email and Password Input Fields
                    Group {
                        Text("Email Address")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 50)
                            .font(Font.custom("Poppins", size: 16))

                        TextField("Email Address", text: $email)
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color("AccentColor3"))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .font(Font.custom("Poppins", size: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isEmailFocused ? Color("AccentColor1") : Color.clear, lineWidth: 2)
                            )
                            .focused($isEmailFocused)
                            .accessibilityIdentifier("emailField")

                        Text("Password")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 50)
                            .font(Font.custom("Poppins", size: 16))

                        SecureField("Password", text: $password)
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color("AccentColor3"))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .font(Font.custom("Poppins", size: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isPasswordFocused ? Color("AccentColor1") : Color.clear, lineWidth: 2)
                            )
                            .focused($isPasswordFocused)
                            .accessibilityIdentifier("passwordField")
                    }

                    // MARK: - Login Button
                    Button(action: {
                        print("🔐 Login button tapped – starting authentication")
                        authenticateUser()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .frame(width: 300, height: 50)

                            Text("Login")
                                .font(Font.custom("Poppins", size: 18))
                                .foregroundColor(Color("AccentColor3"))
                        }
                    }
                    .padding(.top, 30)
                    .accessibilityIdentifier("loginButton")

                    // MARK: - Error Message
                    if wrongUsername > 0 || wrongPassword > 0 {
                        Text("Incorrect Email or Password")
                            .foregroundColor(.red)
                            .font(Font.custom("Poppins", size: 16))
                    }

                    // MARK: - Navigation to Profile Setup if 2FA is not done
                    NavigationLink(destination: ProfileSetupView(), isActive: $navigateToProfileSetup) {
                        EmptyView()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    // MARK: - Firebase Authentication
    /// Authenticates the user with email and password via Firebase Auth.
    func authenticateUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ Firebase login error: \(error.localizedDescription)")
                wrongUsername += 1
                wrongPassword += 1
            } else {
                print("✅ Firebase login successful for: \(email)")
                fetch2FAStatus()
            }
        }
    }

    // MARK: - Fetch 2FA Status
    /// Retrieves the user's 2FA status from Firestore and navigates accordingly.
    func fetch2FAStatus() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                let isVerified = document.data()?["is2FAVerified"] as? Bool ?? false
                print("✅ 2FA status fetched: \(isVerified)")
                if isVerified {
                    appState.isLoggedIn = true
                } else {
                    self.navigateToProfileSetup = true
                }
            } else {
                print("❌ No user document found, assuming 2FA not done")
                self.navigateToProfileSetup = true
            }
        }
    }
}
