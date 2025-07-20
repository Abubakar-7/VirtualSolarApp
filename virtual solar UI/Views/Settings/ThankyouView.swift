import SwiftUI

struct ThankyouView: View {
    @State private var goToDashboard = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                // Logo
                Image("SolarCloudLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)

                // Thank you message
                VStack(spacing: 10) {
                    Text("Thank you,")
                    Text("your message has been")
                    Text("sent to our team, we will")
                    Text("be in touch soon.")
                    Text("")
                    Text("Be wanted we like to")
                    Text("chat.......")
                }
                .font(.system(size: 20))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

                Spacer()

                // Return to Dashboard button
                Button(action: {
                    goToDashboard = true
                }) {
                    Text("Take me back to\nthe Dashboard")
                        .font(.system(size: 20))
                        .foregroundColor(Color("BackgroundColor"))
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Navigation to DashboardView
                NavigationLink(destination: DashboardView(), isActive: $goToDashboard) {
                    EmptyView()
                }
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    ThankyouView()
}
