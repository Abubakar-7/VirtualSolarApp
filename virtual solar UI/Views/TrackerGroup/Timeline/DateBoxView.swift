import SwiftUI

// Displays a date in a styled box: month/year on top, day below
struct DateBoxView: View {
    let date: Date
    
    var body: some View {
        VStack(spacing: 2) {
            // Month and year
            HStack {
                Text(monthString)
                    .font(.custom("Poppins-SemiBold", size: 12))
                    .foregroundColor(.white)
                Text(yearString)
                    .font(.custom("Poppins-SemiBold", size: 12))
                    .foregroundColor(.white)
            }
            // Day
            Text(dayString)
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .frame(width: 75, height: 60) // Fixed size
        .padding(8) // Consistent padding
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("BackgroundColor"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("AccentColor1"), lineWidth: 2)
        )
    }
    // Helper: returns month as uppercase string
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
    // Helper: returns day as string
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    // Helper: returns year as string
    private var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    DateBoxView(date: Date())
        .background(Color("BackgroundColor"))
}
