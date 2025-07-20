import SwiftUI
import FirebaseAuth

// MARK: - MoreView
struct MoreView: View {
    // Enum defining different settings options
    enum SettingOption: String, CaseIterable, Identifiable {
        case myDetails = "My Details"
        case statement = "Statement"
        case allocations = "Allocations"
        case videoExplainer = "Video Explainer"
        case legalDocument = "Legal Document"
        case faq = "FAQ"
        case contactUs = "Contact Us"
        case logout = "Logout"

        var id: String { self.rawValue }
    }

    // MARK: - State Variables
    @State private var selectedOption: SettingOption?
    @State private var shouldNavigateToLogin = false
    @State private var showPopup = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()

                // MARK: - Scrollable Content
                ScrollView {
                    VStack(spacing: 24) {
                        // App logo
                        Image("SolarCloudLogo")
                            .resizable()
                            .frame(width: 28.86, height: 50.0)
                            .padding(.top)

                        // Settings Header
                        HStack {
                            Image("UserIcon")
                                .frame(width: 8, height: 8)
                                .padding()
                            Text("Settings")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.horizontal)

                        // MARK: - Settings Options List
                        VStack(spacing: 16) {
                            ForEach(SettingOption.allCases) { option in
                                // Background NavigationLink for programmatic navigation
                                NavigationLink(
                                    destination: destinationView(for: option),
                                    tag: option,
                                    selection: $selectedOption
                                ) {
                                    EmptyView()
                                }

                                // Visible interactive button
                                Button(action: {
                                    handleOptionTap(option)
                                }) {
                                    HStack {
                                        Text(option.rawValue)
                                            .foregroundColor(.white)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(24)
                        .padding(.horizontal)

                        // Navigation trigger for login screen after logout
                        NavigationLink(destination: LoginView(), isActive: $shouldNavigateToLogin) {
                            EmptyView()
                        }
                    }
                }

                // MARK: - Success Popup Overlay
                if showPopup {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.green)
                                    .scaleEffect(showPopup ? 1.2 : 0.8)
                                    .animation(.easeInOut(duration: 0.3), value: showPopup)

                                Text("Profile updated!")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(radius: 8)
                            .transition(.scale.combined(with: .opacity))
                            Spacer()
                        }
                        Spacer()
                    }
                    .onAppear {
                        // Auto-dismiss popup after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showPopup = false
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Returns the destination view based on selected setting option
    @ViewBuilder
    func destinationView(for option: SettingOption) -> some View {
        switch option {
        case .myDetails:
            MyDetailsView(showUpdatePopup: $showPopup)
        case .statement:
            StatementView()
        case .allocations:
            AllocationsHomeView()
        case .videoExplainer:
            VideoExplainerView()
        case .legalDocument:
            LegalDocumentView()
        case .faq:
            FAQView()
        case .contactUs:
            ContactUsView()
        case .logout:
            EmptyView() // Logout handled separately
        }
    }

    // MARK: - Handles user taps on setting options
    func handleOptionTap(_ option: SettingOption) {
        if option == .logout {
            do {
                try Auth.auth().signOut()
                shouldNavigateToLogin = true
                print("✅ Logged out")
                appState.isLoggedIn = false
            } catch {
                print("❌ Logout failed: \(error.localizedDescription)")
            }
        } else {
            selectedOption = option
        }
    }
}
