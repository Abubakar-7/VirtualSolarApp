import SwiftUI
import FirebaseCore
import FirebaseAuth

/// A view that handles user registration via email and password using Firebase Authentication.
struct EmailSignUpView: View {
    
    // MARK: - User Inputs
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // MARK: - State Flags
    @State private var showingSignUpScreen = false
    @State private var passwordMismatch = false
    @State private var signupErrorMessage: String?
    
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss

    // MARK: - Focus Field Handling
    @FocusState private var focusedField: Field?
    
    /// Enum representing which input field is focused.
    enum Field {
        case email, password, confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()

                VStack {
                    // MARK: - Logo and Title
                    Image("SolarCloudLogo")
                    Image("SolarCloudName")

                    Text("Sign Up")
                        .font(Font.custom("Poppins-Light", size: 40))
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 50)

                    // MARK: - Email Field
                    Text("Email Address")
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 50)
                        .font(Font.custom("Poppins-Light", size: 16))

                    TextField("Email Address", text: $email)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color("AccentColor3"))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(focusedField == .email ? Color("AccentColor1") : Color.clear, lineWidth: 2)
                        )
                        .focused($focusedField, equals: .email)

                    // MARK: - Password Field
                    Text("Password")
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 50)
                        .font(Font.custom("Poppins-Light", size: 16))

                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color("AccentColor3"))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(focusedField == .password ? Color("AccentColor1") : Color.clear, lineWidth: 2)
                        )
                        .focused($focusedField, equals: .password)

                    // MARK: - Confirm Password Field
                    Text("Confirm Password")
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 50)
                        .font(Font.custom("Poppins-Light", size: 16))

                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color("AccentColor3"))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(focusedField == .confirmPassword ? Color("AccentColor1") : Color.clear, lineWidth: 2)
                        )
                        .focused($focusedField, equals: .confirmPassword)

                    // MARK: - Sign Up Button
                    Button("Sign Up") {
                        signUpUser()
                    }
                    .foregroundColor(Color("AccentColor3"))
                    .frame(width: 300, height: 50)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.top, 30.0)

                    // MARK: - Validation Messages
                    if passwordMismatch {
                        Text("Passwords do not match")
                            .foregroundColor(.red)
                    }

                    if let error = signupErrorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                        }
                        .foregroundStyle(Color.white)
                    }
                }
            }
            // Navigate to login screen after successful sign-up
            .navigationDestination(isPresented: $showingSignUpScreen) {
                EmailLoginView()
            }
        }
    }

    // MARK: - Firebase Sign Up Logic

    /// Validates input and creates a new user account using Firebase Authentication.
    func signUpUser() {
        guard password == confirmPassword else {
            passwordMismatch = true
            return
        }

        passwordMismatch = false
        signupErrorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Firebase signup error: \(error.localizedDescription)")
                signupErrorMessage = error.localizedDescription
            } else {
                showingSignUpScreen = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EmailSignUpView()
    }
}
