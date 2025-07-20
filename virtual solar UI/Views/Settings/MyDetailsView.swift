
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MyDetailsView: View {
    // MARK: - Profile Fields
    @State private var firstName = ""
    @State private var middleName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var password = ""
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var country = ""

    // MARK: - Section Toggles
    @State private var showBasicInfo = true
    @State private var showEmail = false
    @State private var showSecurity = false
    @State private var showAddress = false

    // MARK: - Navigation
    @State private var navigateToMoreView = false
    @State private var errorMessage = ""
    
    @Binding var showUpdatePopup: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ✅ Logo
                Image("SolarCloudLogo")
                    .resizable()
                    .frame(width: 28.86, height: 50)
                    .padding(.top)

                // ✅ Custom Back Button + Title
                HStack(spacing: 10) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(Color("AccentColor2"))
                    }

                    Text("Details")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal)

                // MARK: - Sections
                collapsibleSection(title: "Basic info", isExpanded: $showBasicInfo) {
                    Group {
                        profileTextField("First name", text: $firstName)
                        profileTextField("Middle name", text: $middleName)
                        profileTextField("Last name", text: $lastName)
                        profileTextField("Phone", text: $phone)
                    }
                }

                collapsibleSection(title: "Email", isExpanded: $showEmail) {
                    profileTextField("Email", text: $email)
                }

                collapsibleSection(title: "Security", isExpanded: $showSecurity) {
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }

                collapsibleSection(title: "Address", isExpanded: $showAddress) {
                    Group {
                        profileTextField("Street", text: $street)
                        profileTextField("City", text: $city)
                        profileTextField("State", text: $state)
                        profileTextField("Zip Code", text: $zipCode)
                        profileTextField("Country", text: $country)
                    }
                }

                Button(action: updateUserProfile) {
                    Text("Update")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                if !errorMessage.isEmpty {
                    Text("❌ \(errorMessage)")
                        .foregroundColor(.red)
                }

                // Navigation trigger
                NavigationLink(destination: MoreView(), isActive: $navigateToMoreView) {
                    EmptyView()
                }
            }
            .padding()
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .onAppear(perform: loadUserData)
        .navigationBarBackButtonHidden(true) // ✅ Hides default nav back button
    }

    // MARK: - Firestore
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(uid).getDocument { doc, error in
            if let data = doc?.data() {
                self.firstName = data["firstName"] as? String ?? ""
                self.middleName = data["middleName"] as? String ?? ""
                self.lastName = data["lastName"] as? String ?? ""
                self.phone = data["phone"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                self.street = data["street"] as? String ?? ""
                self.city = data["city"] as? String ?? ""
                self.state = data["state"] as? String ?? ""
                self.zipCode = data["zipCode"] as? String ?? ""
                self.country = data["country"] as? String ?? ""
            } else {
                self.errorMessage = error?.localizedDescription ?? "Failed to fetch profile"
            }
        }
    }

    func updateUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let updatedData: [String: Any] = [
            "firstName": firstName,
            "middleName": middleName,
            "lastName": lastName,
            "phone": phone,
            "email": email,
            "street": street,
            "city": city,
            "state": state,
            "zipCode": zipCode,
            "country": country
        ]

        Firestore.firestore().collection("users").document(uid).setData(updatedData, merge: true) { error in
            if let error = error {
                self.errorMessage = "Update failed: \(error.localizedDescription)"
            } else {
                self.showUpdatePopup = true
                self.dismiss()
            }
        }
    }

    // MARK: - UI Components
    func collapsibleSection<Content: View>(title: String, isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 10) {
            Button(action: {
                withAnimation {
                    isExpanded.wrappedValue.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .foregroundColor(.white)
                        .bold()
                    Spacer()
                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.06))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            if isExpanded.wrappedValue {
                VStack(spacing: 10) {
                    content()
                }
                .padding(.top, 4)
            }
        }
    }

    func profileTextField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding(.leading, 4)

            TextField(label, text: text)
                .padding()
                .background(Color("AccentColor3"))
                .cornerRadius(10)
                .foregroundColor(.white)
        }
        .padding(.horizontal)
    }
}
