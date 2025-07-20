import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// View responsible for verifying a 6-digit 2FA code
struct VerifyCodeView: View {
    @State private var userCode: String = ""              // Code input by user
    let expectedCode: String                              // Code expected (sent via email)
    @State private var error = ""                         // Error message shown on failure
    @State private var goToDashboard = false              // Navigation trigger to dashboard

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()

                VStack(spacing: 20) {
                    // Title prompt
                    Text("Enter the code sent to your email")
                        .foregroundColor(.white)
                        .font(.title3)

                    // Code input field
                    TextField("Enter 6-digit code", text: $userCode)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color("AccentColor3"))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)

                    // Error feedback
                    if !error.isEmpty {
                        Text(error)
                            .foregroundColor(.red)
                    }

                    // Verify button
                    Button("Verify") {
                        verifyCode()
                    }
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                }

                // Navigate to dashboard on successful verification
                NavigationLink(destination: NavigationBar(), isActive: $goToDashboard) {
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Code Verification Logic
    private func verifyCode() {
        if userCode == expectedCode {
            guard let uid = Auth.auth().currentUser?.uid else {
                error = "User not logged in"
                return
            }

            // Update 2FA status in Firestore
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData(["is2FAVerified": true], merge: true) { err in
                if let err = err {
                    error = "Failed to update status: \(err.localizedDescription)"
                } else {
                    goToDashboard = true
                }
            }
        } else {
            error = "Incorrect code. Please try again."
        }
    }
}
