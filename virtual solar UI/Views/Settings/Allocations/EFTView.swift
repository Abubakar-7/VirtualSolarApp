import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct EFTView: View {
    @Environment(\.dismiss) var dismiss

    // User input states
    @State private var selectedBank: String = "Choose"
    @State private var showBankPicker = false
    @State private var bsb: String = ""
    @State private var accountNumber: String = ""
    @State private var nickname: String = ""

    // Validation flags
    @State private var showBankError = false
    @State private var showBsbError = false
    @State private var showAccountError = false
    @State private var showNicknameError = false

    // Panel allocation tracking
    @State private var allocatedPanels = 0
    @State private var leftPanels = 6
    @State private var selectedPanels = 1

    // Total panel limit
    @State private var totalPanels = 6

    // List of available banks
    let bankNames = [
        "Choose", "Westpac", "Commonwealth Bank", "ANZ", "NAB",
        "Macquarie Bank", "ING", "Suncorp", "Bank of Queensland", "Bendigo Bank"
    ]

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Centered logo
                    HStack {
                        Spacer()
                        Image("SolarCloudLogo")
                            .resizable()
                            .frame(width: 28.86, height: 50)
                        Spacer()
                    }

                    // Page title and back button
                    HStack(spacing: 10) {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("AccentColor2"))
                        }

                        Text("Bank account")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Subtitle
                    Text("Enter the bank account details where you would like your disbursements magically appear.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Panel summary (allocated / left)
                    HStack {
                        Spacer()
                        VStack {
                            Text("allocated")
                                .font(.caption)
                                .foregroundColor(.gray)
                            VStack {
                                Text("\(allocatedPanels) panels")
                                    .foregroundColor(Color("AccentColor2"))
                                Text("\(String(format: "%.1f", Double(allocatedPanels) * 0.85))kW")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color("AccentColor3"))
                            .cornerRadius(16)
                        }
                        Spacer()
                        VStack {
                            Text("left")
                                .font(.caption)
                                .foregroundColor(.gray)
                            VStack {
                                Text("\(leftPanels) panels")
                                    .foregroundColor(Color("AccentColor2"))
                                Text("\(String(format: "%.1f", Double(leftPanels) * 0.85))kW")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color("AccentColor3"))
                            .cornerRadius(16)
                        }
                        Spacer()
                    }

                    // Panel count selector
                    VStack(spacing: 4) {
                        Text("Panels")
                            .foregroundColor(.white)

                        HStack(spacing: 0) {
                            Button {
                                if selectedPanels > 1 { selectedPanels -= 1 }
                            } label: {
                                Text("–")
                                    .font(.title2)
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color("AccentColor3"))
                            }

                            Text("\(selectedPanels)")
                                .frame(width: 60, height: 40)
                                .background(Color("AccentColor3"))
                                .foregroundColor(.white)

                            Button {
                                if selectedPanels < leftPanels { selectedPanels += 1 }
                            } label: {
                                Text("+")
                                    .font(.title2)
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                                    .background(Color("AccentColor3"))
                            }
                        }
                        .cornerRadius(12)
                    }

                    // Bank details form
                    VStack(alignment: .leading, spacing: 10) {

                        // Bank Name Picker
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bank name")
                                .foregroundColor(.gray)

                            Button {
                                showBankPicker.toggle()
                            } label: {
                                HStack {
                                    Text(selectedBank)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color("AccentColor3"))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(showBankError ? Color.red : Color.clear, lineWidth: 2)
                                )
                            }

                            if showBankError {
                                Text("Please select a bank.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        // BSB Field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("BSB")
                                .foregroundColor(.gray)

                            TextField("Enter BSB", text: $bsb)
                                .padding()
                                .background(Color("AccentColor3"))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(showBsbError ? Color.red : Color.clear, lineWidth: 2)
                                )

                            if showBsbError {
                                Text("BSB is required.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        // Account Number Field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Account number")
                                .foregroundColor(.gray)

                            TextField("Enter Account Number", text: $accountNumber)
                                .padding()
                                .background(Color("AccentColor3"))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(showAccountError ? Color.red : Color.clear, lineWidth: 2)
                                )

                            if showAccountError {
                                Text("Account number is required.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        // Nickname Field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nickname")
                                .foregroundColor(.gray)

                            TextField("Enter Nickname", text: $nickname)
                                .padding()
                                .background(Color("AccentColor3"))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(showNicknameError ? Color.red : Color.clear, lineWidth: 2)
                                )

                            if showNicknameError {
                                Text("Nickname is required.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Add Button
                    Button(action: handleAdd) {
                        Text("Add")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("AccentColor2"))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
        }
        .onAppear(perform: fetchAllocations)
        .sheet(isPresented: $showBankPicker) {
            BankPickerSheet
        }
        .navigationBarBackButtonHidden(true)
    }

    // Handle form submission and validation
    func handleAdd() {
        // Validate fields
        showBankError = selectedBank == "Choose"
        showBsbError = bsb.trimmingCharacters(in: .whitespaces).isEmpty
        showAccountError = accountNumber.trimmingCharacters(in: .whitespaces).isEmpty
        showNicknameError = nickname.trimmingCharacters(in: .whitespaces).isEmpty

        guard !showBankError && !showBsbError && !showAccountError && !showNicknameError else { return }

        // Prepare data for Firestore
        let data: [String: Any] = [
            "bank": selectedBank,
            "bsb": bsb,
            "accountNumber": accountNumber,
            "nickname": nickname,
            "allocatedPanels": selectedPanels,
            "kilowatt": Double(selectedPanels) * 0.85
        ]

        // Save to Firestore under current user
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("bankAccounts")
            .addDocument(data: data) { error in
                if error == nil {
                    print("✅ Bank account saved successfully")
                    dismiss()
                }
            }
    }

    // Fetch current panel allocations from all sources
    func fetchAllocations() {
        allocatedPanels = 0
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let group = DispatchGroup()

        group.enter()
        db.collection("users").document(uid).collection("energyBills").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                for doc in docs {
                    allocatedPanels += doc.data()["allocatedPanels"] as? Int ?? 0
                }
            }
            group.leave()
        }

        group.enter()
        db.collection("users").document(uid).collection("paypalAllocations").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                for doc in docs {
                    allocatedPanels += doc.data()["allocatedPanels"] as? Int ?? 0
                }
            }
            group.leave()
        }

        group.enter()
        db.collection("users").document(uid).collection("bankAccounts").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                for doc in docs {
                    allocatedPanels += doc.data()["allocatedPanels"] as? Int ?? 0
                }
            }
            group.leave()
        }

        // Once all fetches are complete, update remaining panels
        group.notify(queue: .main) {
            leftPanels = max(0, totalPanels - allocatedPanels)
        }
    }

    // Bottom sheet for selecting a bank
    var BankPickerSheet: some View {
        ZStack {
            Color("AccentColor3").ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Select Bank")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(bankNames, id: \.self) { bank in
                            Button(action: {
                                selectedBank = bank
                                showBankPicker = false
                            }) {
                                HStack {
                                    Text(bank)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding()
                                .background(Color("AccentColor3").opacity(0.8))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
