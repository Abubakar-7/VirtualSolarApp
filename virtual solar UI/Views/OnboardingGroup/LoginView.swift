
import SwiftUI
import FirebaseAuth
import GoogleSignInSwift
import GoogleSignIn
import FacebookLogin
import FirebaseCore
import AuthenticationServices
import FirebaseFirestore

// MARK: - Login View

/// Displays the landing screen with slide content and social/email login options.
struct LoginView: View {

    @EnvironmentObject var appState: AppState

    let slides = [
        SlideData(image: "Slide1", title: "Solar anywhere, anytime", description: "If you rent or own an apartment or house, or you own a business, SolarCloud works."),
        SlideData(image: "Slide2", title: "Lower energy bills", description: "If you rent or own an apartment or house, or you own business, SolarCloud works."),
        SlideData(image: "Slide3", title: "We make everything easier", description: "If you rent or own an apartment or house, or you own business, SolarCloud works.")
    ]

    @State private var selectedIndex = 0
    @State private var loginError: String?
    @State private var appleSignInDelegate: AppleSignInDelegate? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color("AccentColor4"), location: 0.0),
                        .init(color: Color("BackgroundColor"), location: 0.5),
                        .init(color: Color("AccentColor4"), location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    Spacer()

                    TabView(selection: $selectedIndex) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            SlideView(data: slides[index])
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 250)

                    HStack(spacing: 5) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            Circle()
                                .fill(index == selectedIndex ? Color("AccentColor1") : Color.white)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.top, 10)

                    Spacer()

                    // MARK: - Social Media Login Buttons
                    VStack(spacing: 10) {
                        SocialLoginButton(title: "Continue with Google", icon: "GoogleIcon") {
                            signInWithGoogle()
                        }
                        .accessibilityIdentifier("googleButton")

                        SocialLoginButton(title: "Continue with Apple", icon: "AppleIcon") {
                            signInWithApple()
                        }
                        .accessibilityIdentifier("appleButton")

                        SocialLoginButton(title: "Continue with Facebook", icon: "FacebookIcon") {
                            signInWithFacebook()
                        }
                        .accessibilityIdentifier("facebookButton")
                    }

                    // MARK: - Email Login Options
                    HStack {
                        NavigationLink(destination: EmailSignUpView()) {
                            Text("Continue with email")
                                .font(Font.custom("Poppins", size: 16))
                                .foregroundColor(.white)
                        }
                        .accessibilityIdentifier("emailSignUpButton")

                        Spacer()

                        NavigationLink(destination: EmailLoginView()) {
                            Text("Login")
                                .font(Font.custom("Poppins", size: 16))
                                .foregroundColor(.white)
                                .bold()
                        }
                        .accessibilityIdentifier("loginButton")
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)

                    Spacer()

                    // MARK: - Login Error
                    if let error = loginError {
                        Text(error)
                            .font(Font.custom("Poppins", size: 14))
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Google Sign-In
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)

        if let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first?.windows.first?.rootViewController {
            
            GIDSignIn.sharedInstance.configuration = config
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    loginError = "Google login failed: \(error.localizedDescription)"
                    return
                }

                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    loginError = "Google token missing"
                    return
                }

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        loginError = "Firebase error: \(error.localizedDescription)"
                    } else if let firebaseUser = authResult?.user {
                        // Add to Firestore
                        let db = Firestore.firestore()
                        db.collection("users").document(firebaseUser.uid).setData([
                            "uid": firebaseUser.uid,
                            "email": firebaseUser.email ?? "unknown",
                            "name": user.profile?.name ?? "No Name"
                        ], merge: true)
                        
                        appState.isLoggedIn = true
                    }
                }
            }
        }
    }
    // MARK: - Facebook Login
    func signInWithFacebook() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], from: nil) { result, error in
            if let error = error {
                loginError = "Facebook login failed: \(error.localizedDescription)"
                return
            }

            guard let token = AccessToken.current?.tokenString else {
                loginError = "Facebook token missing"
                return
            }

            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    loginError = "Firebase error: \(error.localizedDescription)"
                } else if let firebaseUser = authResult?.user {
                    // Add to Firestore
                    let db = Firestore.firestore()
                    db.collection("users").document(firebaseUser.uid).setData([
                        "uid": firebaseUser.uid,
                        "email": firebaseUser.email ?? "unknown",
                        "name": firebaseUser.displayName ?? "No Name"
                    ], merge: true)

                    appState.isLoggedIn = true
                }
            }
        }
    }

    // MARK: - Apple Sign-In
    func signInWithApple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let delegate = AppleSignInDelegate(appState: appState, loginError: $loginError)
        self.appleSignInDelegate = delegate

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = delegate
        controller.performRequests()
    }
}

// MARK: - Apple Sign-In Delegate
class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    let appState: AppState
    let loginError: Binding<String?>

    init(appState: AppState, loginError: Binding<String?>) {
        self.appState = appState
        self.loginError = loginError
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = appleIDCredential.identityToken,
           let tokenString = String(data: identityToken, encoding: .utf8) {

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, accessToken: "")

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.loginError.wrappedValue = "Firebase error: \(error.localizedDescription)"
                    return
                }
                guard let user = authResult?.user else { return }

                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "uid": user.uid,
                    "email": user.email ?? "not_provided@apple.com",
                    "name": "\(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")"
                ], merge: true)

                self.appState.isLoggedIn = true
            }

        } else {
            loginError.wrappedValue = "Apple ID credential missing."
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loginError.wrappedValue = "Apple Sign-In failed: \(error.localizedDescription)"
    }
}

// MARK: - Supporting Views and Data Models

/// Slide content model for the carousel.
struct SlideData {
    let image: String
    let title: String
    let description: String
}

/// View for displaying a single onboarding slide.
struct SlideView: View {
    let data: SlideData

    var body: some View {
        VStack {
            Image(data.image)
                .resizable()
                .scaledToFit()
                .frame(height: 70)
                .accessibilityIdentifier("slide_image_\(data.image)")

            Text(data.title)
                .font(Font.custom("PoppinsSemiBold", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .accessibilityIdentifier("slide_title_\(data.title)")

            Text(data.description)
                .font(Font.custom("Poppins", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 5)
                .accessibilityIdentifier("slide_description_\(data.description)")
        }
        .accessibilityIdentifier("slide_\(data.image)")
    }
}

/// Reusable social login button component.
struct SocialLoginButton: View {
    var title: String
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
                Text(title)
                    .font(Font.custom("Poppins", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.white)
            .cornerRadius(10)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview
#Preview {
    LoginView()
}
