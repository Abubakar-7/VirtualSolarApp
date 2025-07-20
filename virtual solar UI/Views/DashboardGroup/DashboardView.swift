import SwiftUI

/// The main dashboard view that allows users to toggle between active and pending energy data.
struct DashboardView: View {
    
    /// Represents the currently selected tab.
    @State private var selectedTab: DashboardTab = .active

    /// Enum representing the two dashboard states: Active and Pending.
    enum DashboardTab: String, CaseIterable, Hashable {
        case active = "Active"
        case pending = "Pending"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Logo and Header
                    VStack(spacing: 12) {
                        Image("SolarCloudLogo")
                            .resizable()
                            .frame(width: 28.86, height: 50)
                            .padding(.top, 1)

                        HStack(spacing: 8) {
                            Image("SolarIcon")
                                .foregroundColor(Color("AccentColor1"))
                                .fixedSize()
                                .frame(width: 8, height: 8)
                                .padding()

                            Text("Dashboard")
                                .foregroundColor(.white)
                                .font(.custom("Poppins", size: 20))
                                .fontWeight(.semibold)

                            Spacer()
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Tab Switcher
                    HStack(spacing: 12) {
                        ForEach(DashboardTab.allCases, id: \.self) { tab in
                            Button(action: {
                                selectedTab = tab
                            }) {
                                Text(tab.rawValue)
                                    .font(.custom("PoppinsSemiBold", size: 16))
                                    .foregroundColor(selectedTab == tab ? Color("AccentColor1") : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedTab == tab ? Color("AccentColor1") : Color.gray, lineWidth: 4)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Conditional View Rendering
                    Group {
                        if selectedTab == .active {
                            ActiveDashboardView()
                        } else {
                            PendingDashboardView()
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 50)
            }
            .background(Color("BackgroundColor"))
            .ignoresSafeArea()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
}
