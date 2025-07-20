import Foundation

// Model representing a timeline event with unique ID, date, title, description, type, and optional amount.
struct TimelineEvent: Identifiable, Equatable {
    let id = UUID() // Unique identifier for each event
    let date: Date // Event date
    let title: String // Event title
    let description: String // Event description
    let type: NotificationType // Event type (enum)
    let amount: Double? // Optional amount (e.g., payment)

    // Equatable conformance based on unique ID
    static func == (lhs: TimelineEvent, rhs: TimelineEvent) -> Bool {
        lhs.id == rhs.id
    }
}

// Sample data for preview
extension TimelineEvent {
    static let sampleData: [TimelineEvent] = [
        TimelineEvent(
            date: Date().addingTimeInterval(-86400 * 30 * 5), // 5 months ago
            title: "Payment due in 15 days",
            description: "90% of total order amount due, 10 panels, 1kW, 20yr guarantee",
            type: .Reminders,
            amount: 670.50
        ),
        TimelineEvent(
            date: Date().addingTimeInterval(-86400 * 30 * 4), // 4 months ago
            title: "First Payout",
            description: "Received first energy credit payout",
            type: .Payments,
            amount: 120.75
        ),
        TimelineEvent(
            date: Date().addingTimeInterval(-86400 * 30 * 3), // 3 months ago
            title: "System Update",
            description: "We’ve just rolled out a system update to improve performance, enhance data accuracy, and deliver a smoother experience across the SolarCloud platform. This update includes optimizations for energy tracking, faster financial reporting, and improved reliability in real-time panel monitoring. We’ve also resolved minor bugs affecting statement summaries and monthly data visualization. As always, thank you for helping us build a brighter, smarter energy future.",
            type: .Information,
            amount: nil
        ),
        TimelineEvent(
            date: Date().addingTimeInterval(-86400 * 30 * 2), // 2 months ago
            title: "Monthly Payout",
            description: "Energy credit for clear weather period",
            type: .Disbursement,
            amount: 95.20
        ),
        TimelineEvent(
            date: Date().addingTimeInterval(-86400 * 14), // 2 weeks ago
            title: "Add your allocations",
            description: "You can allocate your panels to your home and/or apartment so when your virtual panels are active you are ready to rock and roll",
            type: .RequireActions,
            amount: nil
        )
    ]
}


