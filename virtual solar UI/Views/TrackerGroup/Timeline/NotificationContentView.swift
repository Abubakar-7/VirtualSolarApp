import SwiftUI

// Displays the content of a timeline notification: title, amount, description
struct NotificationContentView: View {
    let event: TimelineEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Top divider for visual separation
            Divider()
                .frame(height: 1)
                .background(Color.gray)
                .padding(.leading, 0)
                .padding(.trailing, 60)
                .padding(.bottom, 4)

            // Event title
            Text(event.title)
                .font(.custom("Poppins-SemiBold", size: 24))
                .foregroundColor(.white)

            // Optional amount, styled by event type
            if let amount = event.amount {
                Text(String(format: "$%.2f", amount))
                    .font(.custom("Poppins-SemiBold", size: 24))
                    .foregroundColor(event.type == .Payments ? Color("AccentColor2") : Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Event description
            Text(event.description)
                .font(.custom("Poppins", size: 16))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
        .background(Color("CardBackground"))
    }
}
