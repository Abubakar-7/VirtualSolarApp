import SwiftUI

struct TimelineEventView: View {
    let event: TimelineEvent
    let nextEventDate: Date?
    let isFirst: Bool
    let isLast: Bool
    
    @State private var dateBoxHeight: CGFloat = 70
    @State private var contentHeight: CGFloat = 60
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Date box with connecting line
            VStack(spacing: 0) {
                DateBoxView(date: event.date)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear { dateBoxHeight = geo.size.height }
                        }
                    )
                    .zIndex(1) // Bring date box above the line
                
                if !isLast {
                    Rectangle()
                        .frame(width: 2)
                        .foregroundColor(Color("AccentColor1"))
                }
            }
            .background(
                // This creates the seamless line behind all date boxes
                VStack(spacing: 0) {
                    if isFirst {
                        Spacer(minLength: dateBoxHeight / 2)
                    }
                    
                    Rectangle()
                        .frame(width: 2)
                        .foregroundColor(Color("AccentColor1"))
                    
                    if isLast {
                        Spacer(minLength: dateBoxHeight / 2)
                    }
                }
                .frame(maxHeight: .infinity)
            )
            
            NotificationContentView(event: event)
                .offset(y: -10) // Adjust to align with the date box
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                contentHeight = geo.size.height
                            }
                    }
                )
        }
    }
}
