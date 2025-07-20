import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct StatementEntry: Identifiable {
    let id = UUID()
    let date: String
    let amount: Double
}

struct PanelGroup: Identifiable {
    let id = UUID()
    let name: String
    let panelCount: Int
    let entries: [StatementEntry]
}

struct StatementView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isExpanded: [UUID: Bool] = [:]
    @State private var selectedPanelName: String = "All"
    @State private var showDropdown = false
    @State private var generalEntries: [StatementEntry] = []
    @State private var panelGroups: [PanelGroup] = []

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Image("SolarCloudLogo")
                        .resizable()
                        .frame(width: 28.86, height: 50)

                    HStack(spacing: 10) {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("AccentColor2"))
                        }

                        Text("Statement")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Button {
                                withAnimation {
                                    showDropdown.toggle()
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("AccentColor3"))
                                    .frame(height: 50)
                                    .overlay(
                                        HStack {
                                            Text(selectedPanelName)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.leading)
                                            Spacer()
                                            Image(systemName: showDropdown ? "chevron.up" : "chevron.down")
                                                .foregroundColor(.white)
                                                .padding(.trailing)
                                        }
                                    )
                            }

                            if showDropdown {
                                VStack(spacing: 6) {
                                    Button(action: {
                                        selectedPanelName = "All"
                                        showDropdown = false
                                    }) {
                                        Text("All")
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color("AccentColor3"))
                                            .cornerRadius(8)
                                    }

                                    ForEach(panelGroups) { group in
                                        Button(action: {
                                            selectedPanelName = group.name
                                            showDropdown = false
                                        }) {
                                            Text(group.name)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color("AccentColor3"))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(.bottom, 16)

                        if selectedPanelName == "All" {
                            ForEach(generalEntries) { entry in
                                entryRow(entry)
                            }

                            ForEach(panelGroups) { group in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text("\(group.name) \(group.panelCount) panels")
                                            .foregroundColor(.white)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Image(systemName: isExpanded[group.id] ?? false ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.white)
                                    }
                                    .onTapGesture {
                                        withAnimation {
                                            isExpanded[group.id] = !(isExpanded[group.id] ?? false)
                                        }
                                    }

                                    if isExpanded[group.id] ?? false {
                                        ForEach(group.entries) { entry in
                                            entryRow(entry)
                                        }
                                    }
                                }
                            }
                        } else {
                            if let group = panelGroups.first(where: { $0.name == selectedPanelName }) {
                                Text("\(group.name) \(group.panelCount) panels")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                ForEach(group.entries) { entry in
                                    entryRow(entry)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
        }
        .onAppear {
            loadMockStatementData()
            // loadStatementData() // ← Use this to load from Firestore
        }
        .navigationBarBackButtonHidden(true)
    }

    func entryRow(_ entry: StatementEntry) -> some View {
        HStack {
            Capsule()
                .fill(Color("AccentColor1"))
                .frame(width: 6, height: 28)

            Text(entry.date)
                .foregroundColor(.white)
                .font(.subheadline)

            Spacer()

            Text(String(format: "$%.2f", entry.amount))
                .foregroundColor(Color("AccentColor1"))
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color("AccentColor3"))
        .cornerRadius(10)
    }

    func loadMockStatementData() {
        generalEntries = [
            StatementEntry(date: "2025-07-01", amount: 18.75),
            StatementEntry(date: "2025-07-03", amount: 22.00)
        ]

        panelGroups = [
            PanelGroup(name: "North Wing", panelCount: 3, entries: [
                StatementEntry(date: "2025-07-02", amount: 7.25),
                StatementEntry(date: "2025-07-05", amount: 10.50)
            ]),
            PanelGroup(name: "South Wing", panelCount: 2, entries: [
                StatementEntry(date: "2025-07-04", amount: 6.00),
                StatementEntry(date: "2025-07-06", amount: 8.30)
            ])
        ]
    }

    /*
    func loadStatementData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let baseRef = db.collection("users").document(userID).collection("statements")

        baseRef.document("general").getDocument { snapshot, _ in
            if let data = snapshot?.data(),
               let entriesData = data["entries"] as? [[String: Any]] {
                generalEntries = entriesData.compactMap { dict in
                    guard let date = dict["date"] as? String,
                          let amount = dict["amount"] as? Double else { return nil }
                    return StatementEntry(date: date, amount: amount)
                }
            }
        }

        baseRef.getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            var groups: [PanelGroup] = []

            for doc in docs where doc.documentID != "general" {
                let name = doc.documentID
                let data = doc.data()
                let panelCount = data["panelCount"] as? Int ?? 0
                if let entriesData = data["entries"] as? [[String: Any]] {
                    let entries: [StatementEntry] = entriesData.compactMap { dict in
                        guard let date = dict["date"] as? String,
                              let amount = dict["amount"] as? Double else {
                            return nil
                        }
                        return StatementEntry(date: date, amount: amount)
                    }
                    groups.append(PanelGroup(name: name, panelCount: panelCount, entries: entries))
                }
            }
            self.panelGroups = groups
        }
    }
    */
}
