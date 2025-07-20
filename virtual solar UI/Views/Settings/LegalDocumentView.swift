
import SwiftUI

struct LegalDocumentView: View {
    @Environment(\.dismiss) var dismiss  // Used to dismiss the current view (go back)

    // List of legal document titles
    let items = [
        "Balance receipt 21/08/2021",
        "Deposit 08/08/2021",
        "Balance receipt 21/06/2021",
        "Deposit 08/06/2021",
        "Replacement PDS",
        "Management Agreement",
        "Constitution",
        "Indicative Return"
    ]

    var body: some View {
        NavigationStack {  // Modern navigation container replacing NavigationView
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()  // Background color

                VStack(spacing: 20) {
                    // App Logo at the top center
                    Image("SolarCloudLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 60)
                        .padding(.bottom, 10)

                    // Custom back button and page title
                    HStack {
                        Button(action: {
                            dismiss()  // Trigger dismissal of current screen
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("AccentColor2"))
                                .font(.title2)
                        }

                        Text("Paperwork")
                            .foregroundColor(.white)
                            .font(.title2.bold())

                        Spacer()
                    }
                    .padding(.horizontal)

                    // Scrollable list of paperwork buttons
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(items, id: \.self) { item in
                                Button(action: {
                                    print("Tapped on \(item)")  // Placeholder for future document viewer
                                }) {
                                    Text(item)
                                        .foregroundColor(.black)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color("AccentColor2"))
                                        .cornerRadius(10)
                                }
                            }

                            // Scroll For More Button (placeholder)
                            Button(action: {
                                print("Scroll for more tapped")
                            }) {
                                Text("scroll for more")
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("AccentColor2"))
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    }

                    Spacer()  // Pushes content to the top
                }
            }
            .navigationBarBackButtonHidden(true)  // Hides the default back button
        }
    }
}

#Preview {
    LegalDocumentView()
}
