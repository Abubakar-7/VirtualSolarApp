import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

/// Data model for an individual solar panel allocation
struct AllocationItem: Identifiable {
    let id: String
    let nickname: String
    let allocatedPanels: Int
    let kilowatt: Double
    let source: String // Indicates the source collection: energyBills, paypalAllocations, bankAccounts
}

/// Main view to display and manage user panel allocations
struct AllocationsHomeView: View {
    
    // MARK: - Environment & Navigation
    @Environment(\.dismiss) var dismiss
    @State private var navigateToAddMore = false

    // MARK: - Data
    @State private var allocations: [AllocationItem] = []
    @State private var totalAllocated = 0
    @State private var totalLeft = 6
    let totalPanels = 6

    // MARK: - Deletion State
    @State private var selectedToDelete: AllocationItem?
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Header Section
                Section {
                    VStack(spacing: 20) {
                        HStack {
                            Spacer()
                            Image("SolarCloudLogo")
                                .resizable()
                                .frame(width: 28.86, height: 50)
                            Spacer()
                        }
                        .padding(.top)

                        HStack(spacing: 10) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(Color("AccentColor2"))
                            }

                            Text("Payouts / Allocations")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Spacer()
                        }
                        .padding(.horizontal)

                        HStack {
                            Spacer()
                            panelInfo(title: "allocated", count: totalAllocated)
                            Spacer()
                            panelInfo(title: "left", count: totalLeft)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color("BackgroundColor"))
                }

                // MARK: - Allocation List
                ForEach(allocations) { allocation in
                    VStack(alignment: .leading, spacing: 12) {
                        // User Info
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text(allocation.nickname)
                                    .font(.headline)
                                    .foregroundColor(Color("AccentColor2"))
                                Text("\(allocation.allocatedPanels) panels allocated")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }

                        // Payout Info
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("Last quarter")
                                    .font(.caption)
                                    .foregroundColor(.white)

                                HStack(spacing: 20) {
                                    payoutBox(label: "last payout", amount: "$200")
                                    payoutBox(label: "Savings", amount: "$40")
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color("AccentColor5"))
                        .cornerRadius(20)
                    }
                    .padding(.vertical, 5)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            selectedToDelete = allocation
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowBackground(Color("BackgroundColor"))
                }

                // MARK: - Add/Buy More Panels
                Section {
                    Button(action: {
                        if totalLeft > 0 {
                            navigateToAddMore = true
                        }
                    }) {
                        Text(totalLeft > 0 ? "Add" : "Buy more")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("AccentColor2"))
                            .foregroundColor(.black)
                            .cornerRadius(30)
                    }
                    .padding()
                    .listRowBackground(Color("BackgroundColor"))
                }
            }
            .listStyle(.plain)
            .background(Color("BackgroundColor"))
            .scrollContentBackground(.hidden)
            .navigationDestination(isPresented: $navigateToAddMore) {
                AllocationsView()
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear(perform: fetchAllocations)
        .alert("Delete Allocation?", isPresented: $showDeleteAlert, presenting: selectedToDelete) { item in
            Button("Delete", role: .destructive) {
                deleteAllocation(item)
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("Are you sure you want to delete this allocation?")
        }
    }

    // MARK: - Allocation Stat Card
    @ViewBuilder
    func panelInfo(title: String, count: Int) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            VStack {
                Text("\(count) panels")
                    .font(.subheadline)
                    .foregroundColor(Color("AccentColor2"))
                Text("\(String(format: "%.1f", Double(count) * 0.85))kW")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color("AccentColor3"))
            .cornerRadius(16)
        }
    }

    // MARK: - Payout Detail Box
    @ViewBuilder
    func payoutBox(label: String, amount: String) -> some View {
        VStack {
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
            Text(amount)
                .foregroundColor(Color("AccentColor2"))
        }
    }

    // MARK: - Fetch All Allocations from Firestore
    func fetchAllocations() {
        allocations = []
        totalAllocated = 0

        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let group = DispatchGroup()

        let sources = ["energyBills", "paypalAllocations", "bankAccounts"]

        for source in sources {
            group.enter()
            db.collection("users").document(uid).collection(source).getDocuments { snapshot, _ in
                if let documents = snapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        let item = AllocationItem(
                            id: doc.documentID,
                            nickname: data["nickname"] as? String ?? "",
                            allocatedPanels: data["allocatedPanels"] as? Int ?? 0,
                            kilowatt: data["kilowatt"] as? Double ?? 0.0,
                            source: source
                        )
                        allocations.append(item)
                        totalAllocated += item.allocatedPanels
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            totalLeft = max(0, totalPanels - totalAllocated)
        }
    }

    // MARK: - Delete an Allocation from Firestore
    func deleteAllocation(_ allocation: AllocationItem) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users")
            .document(uid)
            .collection(allocation.source)
            .document(allocation.id)
            .delete { error in
                if let error = error {
                    print("Delete failed: \(error.localizedDescription)")
                } else {
                    allocations.removeAll { $0.id == allocation.id && $0.source == allocation.source }
                    totalAllocated -= allocation.allocatedPanels
                    totalLeft = max(0, totalPanels - totalAllocated)
                }
            }
    }
}

// MARK: - Preview
#Preview {
    AllocationsHomeView()
}
