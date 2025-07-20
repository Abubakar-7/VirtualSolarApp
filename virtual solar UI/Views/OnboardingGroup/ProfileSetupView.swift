import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// View to collect user's name and email, then initiate 2FA by sending a verification code via email.
struct ProfileSetupView: View {
    
    // MARK: - User Input States
    @State private var name: String = ""
    @State private var email: String = ""

    // MARK: - Verification Code
    @State private var code: String = ""
    
    // MARK: - Navigation
    @State private var showVerifyCodeView = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()

                VStack(spacing: 25) {
                    // MARK: - Logo
                    Image("SolarCloudLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding(.top, 20)

                    Text("Your profile name")
                        .font(.title)
                        .foregroundColor(.white)

                    // MARK: - Input Fields
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your name")
                            .foregroundColor(.gray)

                        TextField("Your name", text: $name)
                            .padding()
                            .background(Color("AccentColor3"))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.cyan, lineWidth: 1)
                            )

                        Text("Your Email")
                            .foregroundColor(.gray)

                        TextField("you@example.com", text: $email)
                            .padding()
                            .background(Color("AccentColor3"))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 30)

                    // MARK: - Send Verification Code
                    Button(action: {
                        sendCodeToEmail()
                    }) {
                        Text("Setup Two-Factor Authentication")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("AccentColor3"))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)

                    // MARK: - Navigation to VerifyCodeView
                    NavigationLink(
                        destination: VerifyCodeView(expectedCode: code),
                        isActive: $showVerifyCodeView
                    ) {
                        EmptyView()
                    }
                }
            }
        }
    }

    // MARK: - Send Email with 2FA Code
    /// Generates a random 6-digit code and sends it to the user's email via SendGrid.
    /// If successful, saves user profile to Firestore and shows the verification view.
    func sendCodeToEmail() {
        let randomCode = String(format: "%06d", Int.random(in: 100000...999999))
        self.code = randomCode

        // Payload for SendGrid email
        let payload: [String: Any] = [
            "personalizations": [[
                "to": [["email": email]],
                "subject": "Your SolarCloud Verification Code"
            ]],
            "from": ["email": "abubakarabbas790@gmail.com"],
            "content": [[
                "type": "text/plain",
                "value": "Hi \(name),\n\nYour SolarCloud verification code is: \(randomCode)"
            ]]
        ]

        guard let url = URL(string: "https://api.sendgrid.com/v3/mail/send"),
              let body = try? JSONSerialization.data(withJSONObject: payload) else {
            print("❌ Failed to encode request body")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Secrets.sendGridKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        // Perform the network call
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to send email: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 202 {
                    print("✅ Code sent to \(email): \(randomCode)")
                    showVerifyCodeView = true

                    // Save user profile to Firestore
                    if let uid = Auth.auth().currentUser?.uid {
                        let db = Firestore.firestore()
                        db.collection("users").document(uid).setData([
                            "name": name,
                            "email": email
                        ], merge: true) { err in
                            if let err = err {
                                print("❌ Failed to store user profile: \(err.localizedDescription)")
                            } else {
                                print("✅ User profile saved to Firestore.")
                            }
                        }
                    }
                } else {
                    print("❌ Error sending email or invalid response")
                }
            }
        }.resume()
    }
}
