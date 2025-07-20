import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct EnergyBillView: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedCompany: String = "Choose"
    @State private var showCompanyPicker = false
    @State private var billerCode: String = ""
    @State private var reference: String = ""
    @State private var nickname: String = ""

    // Validation flags
    @State private var showCompanyError = false
    @State private var showBillerCodeError = false
    @State private var showReferenceError = false
    @State private var showNicknameError = false

    @State private var allocatedPanels = 0
    @State private var leftPanels = 6
    @State private var totalPanels = 6

    @State private var selectedPanels = 1

    let energyCompanies = [
        "Choose", "AGL", "Origin Energy", "EnergyAustralia", "Red Energy",
        "Powershop", "Simply Energy", "Lumo Energy", "Alinta Energy",
        "Momentum Energy", "Tango Energy", "Diamond Energy", "Amber Electric",
        "Blue NRG", "Nectr", "Sumo", "OVO Energy", "ReAmped Energy"
    ]

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Logo
                    HStack {
                        Spacer()
                        Image("SolarCloudLogo")
                            .resizable()
                            .frame(width: 28.86, height: 50)
                        Spacer()
                    }

                    // Title + Back
                    HStack(spacing: 10) {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("AccentColor2"))
                        }

                        Text("Energy company")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal)

                    // Description
                    Text("Enter the BPAY details from your Energy company's bill.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Allocated Panels
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

                    // Panel Selector
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

                    // Fields
                    VStack(alignment: .leading, spacing: 10) {
                        // Energy Company Picker
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Select Energy Company")
                                .foregroundColor(.gray)

                            Button {
                                showCompanyPicker.toggle()
                            } label: {
                                HStack {
                                    Text(selectedCompany)
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
                                        .stroke(showCompanyError ? Color.red : Color.clear, lineWidth: 2)
                                )
                            }

                            if showCompanyError {
                                Text("Please select a valid company.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        // Biller Code
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Biller Code:")
                                .foregroundColor(.gray)
                            TextField("Enter Biller Code", text: $billerCode)
                                .padding()
                                .background(Color("AccentColor3"))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(showBillerCodeError ? Color.red : Color.clear, lineWidth: 2)
                                )

                            if showBillerCodeError {
                                Text("Biller code is required.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        // Reference
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reference:")
                                .foregroundColor(.gray)
                            TextField("Enter Reference", text: $reference)
                                .padding()
                                .background(Color("AccentColor3"))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(showReferenceError ? Color.red : Color.clear, lineWidth: 2)
                                )

                            if showReferenceError {
                                Text("Reference is required.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }

                        // Nickname
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nickname:")
                                .foregroundColor(.gray)
                            TextField("Enter nickname", text: $nickname)
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
        .sheet(isPresented: $showCompanyPicker) {
            CompanyPickerSheet
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Functions
    func handleAdd() {
        showCompanyError = selectedCompany == "Choose"
        showBillerCodeError = billerCode.trimmingCharacters(in: .whitespaces).isEmpty
        showReferenceError = reference.trimmingCharacters(in: .whitespaces).isEmpty
        showNicknameError = nickname.trimmingCharacters(in: .whitespaces).isEmpty

        guard !showCompanyError && !showBillerCodeError && !showReferenceError && !showNicknameError else { return }

        let data: [String: Any] = [
            "company": selectedCompany,
            "billerCode": billerCode,
            "reference": reference,
            "nickname": nickname,
            "allocatedPanels": selectedPanels,
            "kilowatt": Double(selectedPanels) * 0.85
        ]

        guard let uid = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("energyBills")
            .addDocument(data: data) { error in
                if error == nil {
                    print("✅ Energy bill info saved successfully")
                    dismiss()
                }
            }
    }

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

        group.notify(queue: .main) {
            leftPanels = max(0, totalPanels - allocatedPanels)
        }
    }

    var CompanyPickerSheet: some View {
        ZStack {
            Color("AccentColor3").ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Select Energy Company")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(energyCompanies, id: \.self) { company in
                            Button(action: {
                                selectedCompany = company
                                showCompanyPicker = false
                            }) {
                                HStack {
                                    Text(company)
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
#Preview {
    EnergyBillView()
}
