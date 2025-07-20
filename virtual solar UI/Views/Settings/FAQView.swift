import SwiftUI
import FirebaseFirestore

// Model to represent each FAQ item
struct FAQItem: Identifiable {
    let id: String
    let question: String
    let answer: String
    var isExpanded: Bool = false

    // Custom initializer for FAQItem
    init(id: String, question: String, answer: String, isExpanded: Bool = false) {
        self.id = id
        self.question = question
        self.answer = answer
        self.isExpanded = isExpanded
    }

    // Initializer to parse data from Firestore dictionary
    init(from dict: [String: Any]) {
        self.id = dict["id"] as? String ?? UUID().uuidString
        self.question = dict["question"] as? String ?? "Unknown question"
        self.answer = dict["answer"] as? String ?? "Unknown answer"
        self.isExpanded = false
    }
}

// Main view for displaying FAQ content
struct FAQView: View {
    @Environment(\.dismiss) var dismiss
    @State private var faqs: [FAQItem] = [] // State variable to store FAQs

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()

                VStack(spacing: 20) {
                    // Logo
                    HStack {
                        Spacer()
                        Image("SolarCloudLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 60)
                        Spacer()
                    }
                    .padding(.top)

                    // Back Button and Page Title
                    HStack(spacing: 10) {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(Color("AccentColor2"))
                        }

                        Text("FAQ")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal)

                    // FAQ Cards in ScrollView
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(faqs.indices, id: \.self) { index in
                                FAQCard(faq: $faqs[index]) // Pass binding for state update
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .onAppear {
                fetchFAQsFromFirestore() // Load FAQs from Firestore
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    // Function to fetch FAQ data from Firestore
    func fetchFAQsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("faq").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching FAQs: \(error.localizedDescription)")
                return
            }

            guard let docs = snapshot?.documents else { return }

            // Parse documents into FAQItem models
            self.faqs = docs.map { doc in
                FAQItem(from: doc.data())
            }
        }
    }
}

// Reusable card component for displaying a single FAQ
struct FAQCard: View {
    @Binding var faq: FAQItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(faq.question)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: faq.isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.white)
                    .onTapGesture {
                        withAnimation {
                            faq.isExpanded.toggle() // Expand/collapse logic
                        }
                    }
            }

            // Display answer if expanded
            if faq.isExpanded {
                Text(faq.answer)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color("AccentColor5"))
        .cornerRadius(12)
    }
}

#Preview {
    FAQView()
}
