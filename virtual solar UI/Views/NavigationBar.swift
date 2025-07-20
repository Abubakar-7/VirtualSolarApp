import SwiftUI

// Main container with navigation tabs
struct NavigationBar: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()

            VStack(spacing: 0) {
                // Dynamic view based on selected tab
                switch selectedTab {
                case 0:
                    DashboardView()
                case 1:
                    TrackerView()
                case 2:
                    CalculatorView()
                case 3:
                    MoreView()
                default:
                    DashboardView()
                }

                // Custom bottom tab bar
                CustomTabBar(selectedTab: $selectedTab)
                    .background(
                        Rectangle()
                            .fill(Color("BackgroundColor"))
                            .frame(height: 60)
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: -5)
                    )
            }
        }
    }
}

// Custom tab bar with icons and labels
struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            TabBarButton(icon: "SolarIcon", text: "Dashboard", isSelected: selectedTab == 0)
                .onTapGesture { selectedTab = 0 }

            Spacer()

            TabBarButton(icon: "ListIcon", text: "Tracker", isSelected: selectedTab == 1)
                .onTapGesture { selectedTab = 1 }

            Spacer()

            TabBarButton(icon: "CalculatorIcon", text: "Calculator", isSelected: selectedTab == 2)
                .onTapGesture { selectedTab = 2 }

            Spacer()

            TabBarButton(icon: "UserIcon", text: "More", isSelected: selectedTab == 3)
                .onTapGesture { selectedTab = 3 }
        }
        .padding(.horizontal, 30) // spacing between tab items
        .frame(height: 60) // height of tab bar container
        .background(Color("BackgroundColor"))
    }
}

// Individual tab bar item
struct TabBarButton: View {
    var icon: String
    var text: String
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .foregroundColor(isSelected ? Color("AccentColor1") : .gray)

            Text(text)
                .foregroundColor(isSelected ? Color("AccentColor1") : .gray)
                .font(.custom("Poppins", size: 12))
        }
    }
}

#Preview {
    NavigationBar()
}
