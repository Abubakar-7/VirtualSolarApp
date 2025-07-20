// Enum representing different notification types for timeline events
enum NotificationType: String, Equatable {
    case Disbursement = "Disbursement"
    case Reminders = "Reminders"
    case Information = "Information"
    case RequireActions = "Require Actions"
    case Payments = "Payments"
}
