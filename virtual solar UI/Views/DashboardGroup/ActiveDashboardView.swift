
import SwiftUI
import Charts
import Firebase
import FirebaseFirestore
import FirebaseAuth

// MARK: - Data Model

/// Represents a single day's energy data entry.
struct DayEnergyData: Identifiable {
    var id = UUID()
    var dayString: String
    var kW: Double
    var date: Date
}

// MARK: - Active Dashboard View

/// Displays the dashboard view with energy statistics, charts, and user savings insights.
struct ActiveDashboardView: View {
    enum FocusedField {
        case dec
    }

    @State private var dailyEnergyData: [DayEnergyData] = []
    @State private var currentDate = Date()
    @State private var energyBillAmount = ""
    @State private var activePower = ""
    @State private var totalEnergy = ""
    @State private var totalCO2Saved = ""
    @State private var lastQuarterSavings = ""
    @State private var totalSavings = ""
    @State private var thisQuarterToDate = ""
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                allocationNavigationButton
                savingsSection
                virtualPanelsSection
            }
            .padding(.bottom, 50)
            .onAppear {
                loadMockDataForMonth(currentDate)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
        }
    }

    // MARK: - Current Month Display

    private var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private func loadMockDataForMonth(_ date: Date) {
        currentDate = date
        energyBillAmount = "120"
        activePower = "270"
        totalEnergy = "930"
        totalCO2Saved = "123.45"
        lastQuarterSavings = "65"
        totalSavings = "410"
        thisQuarterToDate = "29"

        let calendar = Calendar.current
        let isCurrentMonth = calendar.isDate(date, equalTo: Date(), toGranularity: .month)
        let isCurrentYear = calendar.isDate(date, equalTo: Date(), toGranularity: .year)

        let dayLimit: Int
        if isCurrentMonth && isCurrentYear {
            dayLimit = calendar.component(.day, from: Date())
        } else {
            dayLimit = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        }

        dailyEnergyData = (1...dayLimit).map { day in
            DayEnergyData(
                dayString: "\(day)",
                kW: Double.random(in: 50...200),
                date: calendar.date(bySetting: .day, value: day, of: date) ?? Date()
            )
        }
    }


    private func canNavigateToNextMonth() -> Bool {
        Calendar.current.date(byAdding: .month, value: 1, to: currentDate)! <= Date()
    }

    private var calculatedSavingsPercentage: Double {
        guard let oldBill = Double(energyBillAmount),
              oldBill > 0,
              let lastQuarter = Double(lastQuarterSavings) else {
            return 0
        }
        return min(lastQuarter / oldBill, 1.0)
    }

    private func loadDataForMonth(_ date: Date) {
        currentDate = date
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let monthKey = formatter.string(from: date)

        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("energyData").document(monthKey).getDocument { docSnapshot, _ in
            guard let data = docSnapshot?.data(),
                  let entries = data["entries"] as? [[String: Any]] else { return }

            activePower = data["activePower"] as? String ?? "0"

            dailyEnergyData = entries.compactMap { dict in
                guard let kW = dict["kW"] as? Double,
                      let dayString = dict["dayString"] as? String,
                      let timestamp = dict["date"] as? Timestamp else { return nil }
                return DayEnergyData(dayString: dayString, kW: kW, date: timestamp.dateValue())
            }

            let totalKW = dailyEnergyData.reduce(0) { $0 + $1.kW }
            totalEnergy = String(format: "%.1f", totalKW)
            totalCO2Saved = String(format: "%.2f", totalKW * 0.133)

            let firstQuarter = dailyEnergyData.sorted(by: { $0.date < $1.date }).prefix(7)
            let lastQuarterKW = firstQuarter.reduce(0) { $0 + $1.kW }
            lastQuarterSavings = String(format: "%.0f", lastQuarterKW * 0.25)

            let day = Calendar.current.component(.day, from: date)
            let quarterRange: ClosedRange<Int> = (1...7).contains(day) ? 1...7 : (8...14).contains(day) ? 8...14 : (15...21).contains(day) ? 15...21 : 22...31
            let thisQuarterKW = dailyEnergyData.filter {
                if let d = Int($0.dayString) {
                    return quarterRange.contains(d)
                }
                return false
            }.reduce(0) { $0 + $1.kW }
            thisQuarterToDate = String(format: "%.0f", thisQuarterKW * 0.25)

            db.collection("users").document(uid).collection("energyData").getDocuments { snapshot, _ in
                guard let selectedDate = formatter.date(from: monthKey) else { return }
                let total: Double = snapshot?.documents.reduce(0) { sum, doc in
                    guard let docDate = formatter.date(from: doc.documentID), docDate <= selectedDate else { return sum }
                    let kWList = (doc.data()["entries"] as? [[String: Any]])?.compactMap { $0["kW"] as? Double } ?? []
                    return sum + kWList.reduce(0, +)
                } ?? 0
                totalSavings = String(format: "%.0f", total * 0.25)
            }
        }
    }

    // MARK: - UI Sections

    private var allocationNavigationButton: some View {
        HStack {
            NavigationLink(destination: AllocationsHomeView()) {
                HStack {
                    Text("Select allocations")
                        .font(.custom("PoppinsSemiBold", size: 16))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color("AccentColor5"))
                .cornerRadius(8)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private var savingsSection: some View {
        VStack(alignment: .leading, spacing: 25) {
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    InfoCard(title: "Active", value: "\(activePower) kW")
                    InfoCard(title: "Last quarter", value: "$\(lastQuarterSavings)")
                }
                HStack(spacing: 10) {
                    InfoCard(title: "Total savings", value: "$\(totalSavings)")
                    InfoCard(title: "This quarter to date", value: "$\(thisQuarterToDate)")
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 36)
            savingsData
        }
        .frame(maxWidth: 330)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color("AccentColor4"))
        .cornerRadius(26)
    }

    private var savingsData: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Text("Savings")
                    .font(.custom("Poppins-SemiBold", size: 34))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.bottom, 20)

            HStack {
                SavingsProgressCircle(percentage: calculatedSavingsPercentage)
                    .padding(.top, 20)
                    .padding(.leading, 20)
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last quarter")
                        .font(.custom("Poppins-SemiBold", size: 15))
                        .foregroundColor(.white)
                    Text("$\(lastQuarterSavings)")
                        .font(.custom("Poppins-SemiBold", size: 22))
                        .foregroundColor(Color("AccentColor2"))
                    Text("Old energy bill")
                        .font(.custom("Poppins-SemiBold", size: 15))
                        .foregroundColor(.white)
                    HStack {
                        Text("$")
                            .font(.custom("Poppins-SemiBold", size: 22))
                            .foregroundColor(Color("AccentColor2"))
                        TextField("Amount", text: $energyBillAmount)
                            .focused($focusedField, equals: .dec)
                            .keyboardType(.decimalPad)
                            .font(.custom("Poppins-SemiBold", size: 22))
                            .foregroundColor(Color("AccentColor2"))
                            .frame(width: 92)
                    }
                }
                .padding(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Rectangle()
                .fill(Color("AccentColor2"))
                .frame(width: 300, height: 1.5)
                .padding(.top, 33)
                .padding(.bottom, 6)

            (
                Text("To eliminate your Electricity Bill visit our ")
                    .font(.custom("Poppins", size: 13))
                    .foregroundColor(.white)
                +
                Text("website")
                    .font(.custom("Poppins", size: 13))
                    .foregroundColor(.white)
                    .underline()
                +
                Text(" to update your SolarCloud portfolio.")
                    .font(.custom("Poppins", size: 13))
                    .foregroundColor(.white)
            )
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }

    private var virtualPanelsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Spacer()
                Text("My virtual panels")
                    .font(.custom("Poppins-SemiBold", size: 34))
                    .foregroundColor(.white)
                Spacer()
            }

            HStack {
                Button {
                    if let previous = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
                        loadDataForMonth(previous)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color("BackgroundColor"))
                        .clipShape(Circle())
                }
                .padding(.leading, 22)

                Spacer()

                Text(currentMonthYear)
                    .foregroundColor(.white)
                    .font(.custom("Poppins-SemiBold", size: 24))

                Spacer()

                Button {
                    if let next = Calendar.current.date(byAdding: .month, value: 1, to: currentDate),
                       next <= Date() {
                        loadDataForMonth(next)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(canNavigateToNextMonth() ? .white : .gray)
                        .frame(width: 36, height: 36)
                        .background(Color("BackgroundColor"))
                        .clipShape(Circle())
                }
                .padding(.trailing, 22)
                .disabled(!canNavigateToNextMonth())
            }

            HStack {
                VStack {
                    Text("Active")
                        .font(.custom("Poppins", size: 16))
                        .foregroundColor(.white)
                    Text(totalEnergy)
                        .font(.headline)
                        .foregroundColor(Color("AccentColor1"))
                    Image("LineGraphIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 24)
                }

                Spacer()

                Image("CO2Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 24)

                Text("\(totalCO2Saved) Kg's")
                    .font(.custom("Poppins", size: 16))
                    .foregroundColor(Color("AccentColor1"))
                +
                Text(" saved")
                    .font(.custom("Poppins", size: 16))
                    .foregroundColor(.white)
            }

            // Energy chart
            HStack(alignment: .top, spacing: 0) {
                Chart {
                    ForEach([0], id: \.self) { _ in
                        BarMark(x: .value("", ""), y: .value("", 0)).opacity(0)
                    }
                }
                .chartYScale(domain: 0...450)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .stride(by: 100)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let kW = value.as(Double.self) {
                                Text("\(Int(kW))")
                                    .font(.custom("Poppins", size: 14))
                                    .foregroundColor(.white)
                                    .offset(y: -10)
                            }
                        }
                    }
                }
                .chartXAxis(.hidden)
                .frame(width: 40, height: 260)
                .padding(.trailing, 4)

                ScrollView(.horizontal, showsIndicators: false) {
                    Chart {
                        ForEach(dailyEnergyData) { dayData in
                            BarMark(
                                x: .value("Day", dayData.dayString),
                                y: .value("kW", dayData.kW)
                            )
                            .foregroundStyle(Color("AccentColor1"))
                            .annotation(position: .top) {
                                Text("\(Int(dayData.kW))")
                                    .font(.custom("Poppins", size: 14))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .chartYScale(domain: 0...450)
                    .chartYAxis(.hidden)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let day = value.as(String.self) {
                                    Text(day)
                                        .font(.custom("Poppins", size: 14))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .frame(width: CGFloat(dailyEnergyData.count) * 40, height: 260)
                }
            }
        }
        .frame(maxWidth: 330)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color("AccentColor4"))
        .cornerRadius(26)
    }
}

// MARK: - Info Card

/// A reusable card view displaying a title and corresponding value.
struct InfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundColor(Color("AccentColor2"))
                .padding(.bottom, 10)
        }
        .padding()
        .frame(width: 150, height: 140)
        .background(Color("BackgroundColor"))
        .cornerRadius(12)
    }
}

// MARK: - Savings Progress Circle

/// A circular progress indicator representing savings percentage visually.
struct SavingsProgressCircle: View {
    var percentage: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("BackgroundColor"), lineWidth: 12)
                .frame(width: 100, height: 100)
            Circle()
                .trim(from: 0, to: percentage)
                .stroke(Color("AccentColor1"), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 100, height: 100)
                .animation(.easeOut(duration: 1.0), value: percentage)
            VStack {
                Text("\(Int(percentage * 100))%")
                    .font(.custom("Poppins-SemiBold", size: 22))
                    .foregroundColor(.white)
                Text("saved")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ActiveDashboardView()
}
