import SwiftUI

// DropdownMenu: Combines a button and a dropdown list for selection
struct DropdownMenu: View {
    let options: [String]
    @Binding var selectedOption: String?
    var onSelect: (String) -> Void
    @Binding var expandedID: String?
    let id: String
    let xOffset: CGFloat
    let yOffset: CGFloat
    // Determines if this dropdown is expanded
    var isExpanded: Bool { expandedID == id }
    
    var body: some View {
        ZStack { // Dropdown button always visible
            DropdownButton(
                selectedOption: selectedOption,
                isExpanded: isExpanded,
                yOffset: isExpanded ? 16 : 0,
                action: {
                    withAnimation {
                        expandedID = isExpanded ? nil : id
                    }
                }
            )
            .zIndex(2)
            
            if isExpanded { // Dropdown list appears when expanded
                DropdownList(
                    options: options,
                    selectedOption: $selectedOption,
                    expandedID: $expandedID,
                    id: id,
                    onSelect: onSelect,
                    xOffset: xOffset,
                    yOffset: yOffset
                )
                .zIndex(1)
                .offset(y: yOffset)
            }
        }
        .frame(width: 160, height: 36)
        
    }
}

// DropdownButton: The clickable button for the dropdown
private struct DropdownButton: View {
    let selectedOption: String?
    let isExpanded: Bool
    let yOffset: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(selectedOption ?? "Select")
                    .font(.custom("Poppins", size: 15))
                    .foregroundColor(isExpanded ? Color("AccentColor2") : .white)
                    .padding(.leading, 3)
                    .frame(minWidth: 120, alignment: .leading)
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(width: 160, height: 36)
        .background(Color("AccentColor6"))
        .clipShape(Capsule())
        .offset(y: yOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isExpanded)
    }
}

// DropdownList: The list of selectable options, with dividers between items
private struct DropdownList: View {
    let options: [String]
    @Binding var selectedOption: String?
    @Binding var expandedID: String?
    let id: String
    let onSelect: (String) -> Void
    let xOffset: CGFloat
    let yOffset: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                Button {
                    withAnimation {
                        selectedOption = option
                        onSelect(option)
                        expandedID = nil
                    }
                } label: {
                    HStack {
                        Text(option)
                            .font(.custom("Poppins", size: 16))
                            .foregroundColor(selectedOption == option ? Color("AccentColor2") : .white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(PlainButtonStyle())
                
                if index < options.count - 1 {
                    Rectangle()
                        .fill(Color("AccentColor2"))
                        .frame(height: 1)
                        .padding(.horizontal, 36)
                }
            }
            
        }
        .padding(.vertical, 20)
        .background(Color("AccentColor5"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(width: 280)
        .offset(x: xOffset)
    }
}
