
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

/// ContactUsView allows users to submit their name, preferred contact method,
/// and a message to the support team. It stores data to Firestore and
/// redirects to a Thank You screen upon success.
struct ContactUsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState // Used for shared app state transitions

    @State private var name: String = ""
    @State private var selectedMethod: String = "Phone"
    @State private var contactInput: String = ""
    @State private var message: String = ""
    @State private var navigateToThankYou = false

    let methods = ["Phone", "Email"] // Available contact methods

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo header
                    HStack {
                        Spacer()
                        Image("SolarCloudLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28.86, height: 50)
                        Spacer()
                    }
                    .padding(.top)

                    // Back button and screen title
                    HStack(spacing: 10) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color("AccentColor2"))
                        }

                        Text("Contact us")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal)

                    // Static phone info
                    Text("ph. 02 8579 2000")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentColor2"))
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // User's name input
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your name")
                            .foregroundColor(.gray)

                        TextField("Enter name", text: $name)
                            .padding()
                            .background(Color("AccentColor3"))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)

                    // Preferred contact method selection
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Preferred contact method")
                            .foregroundColor(.gray)

                        Menu {
                            ForEach(methods, id: \.self) { method in
                                Button(action: {
                                    selectedMethod = method
                                }) {
                                    Text(method)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedMethod)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color("AccentColor3"))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    // Contact input field based on method
                    if selectedMethod == "Phone" {
                        // Phone input
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Number you wish us to contact you on:")
                                .foregroundColor(.gray)

                            TextField("Must be 10 digits", text: $contactInput)
                                .keyboardType(.phonePad)
                                .padding()
                                .background(Color("AccentColor3"))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    } else {
                        // Email input
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Email address you wish us to contact by")
                                .foregroundColor(.gray)

                            TextField("example@email.com", text: $contactInput)
                                .keyboardType(.emailAddress)
                                .padding()
                                .background(Color("AccentColor3"))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)

                        // Message box
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your message")
                                .foregroundColor(.gray)

                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("AccentColor3"))
                                    .frame(height: 100)

                                TextEditor(text: $message)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Color.clear)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Submit button
                    Button(action: {
                        handleSubmit()
                    }) {
                        Text("Submit")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("AccentColor2"))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    Spacer(minLength: 30)

                    // Navigation link to thank you page
                    NavigationLink(destination: ThankyouView().environmentObject(appState), isActive: $navigateToThankYou) {
                        EmptyView()
                    }
                }
                .padding(.top)
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
        }
    }

    /// Validates inputs and submits the contact request to Firestore
    func handleSubmit() {
        guard !name.isEmpty, !contactInput.isEmpty else {
            print("❌ Please fill all fields")
            return
        }

        let data: [String: Any] = [
            "name": name,
            "contactMethod": selectedMethod,
            "contactInput": contactInput,
            "message": message,
            "timestamp": Timestamp()
        ]

        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("contactUsRequests")
            .addDocument(data: data) { error in
                if let error = error {
                    print("❌ Failed to save contact request: \(error.localizedDescription)")
                } else {
                    print("✅ Contact request saved successfully")
                    navigateToThankYou = true
                }
            }
    }
}
