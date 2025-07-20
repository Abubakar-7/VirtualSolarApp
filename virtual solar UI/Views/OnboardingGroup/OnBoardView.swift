//
//  Created by Abubakar Abbas on 5/3/2025.
//

import SwiftUI

/// The onboarding splash screen shown when the app launches.
/// Fades in the logo and transitions to the `LoginView` after a short delay.
struct OnBoardView: View {
    
    // MARK: - State Variables
    
    /// Controls whether to show the main login screen.
    @State private var isActive = false

    /// Controls the fade-in animation of the logo.
    @State private var opacity = 0.0

    var body: some View {
        NavigationStack {
            if isActive {
                // After delay, navigate to login screen
                LoginView()
            } else {
                ZStack {
                    // MARK: - Background Gradient
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color("AccentColor4"), location: 0.0),
                            .init(color: Color("BackgroundColor"), location: 0.5),
                            .init(color: Color("AccentColor4"), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    // MARK: - Logo & Title
                    VStack {
                        // App logo
                        Image("SolarCloudLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .opacity(opacity)
                            .onAppear {
                                withAnimation(.easeIn(duration: 1.5)) {
                                    opacity = 1.0
                                }
                            }

                        // App name with stylized "SOLAR" and "CLOUD"
                        Text("SOLAR")
                            .font(.custom("Poppins", size: 28).weight(.bold))
                            .foregroundColor(.yellow)
                        + Text("CLOUD")
                            .font(.custom("Poppins", size: 28).weight(.bold))
                            .foregroundColor(.gray)
                    }
                }
                .onAppear {
                    // Navigate to login screen after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
            }
        }
    }

    // MARK: - Preview
    struct OnBoardView_Previews: PreviewProvider {
        static var previews: some View {
            OnBoardView()
        }
    }
}

#Preview {
    OnBoardView()
}
