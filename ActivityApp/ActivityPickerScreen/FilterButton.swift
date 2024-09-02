import SwiftUI

struct FilterButton: View
{
    let tag: MapFilter
    
    let tagManager: FilterManager
    
    var body: some View
    {
        filterLabel
            .background { filterBackground }
            .padding(.vertical, 14)
            .padding(.bottom, 30)
            .contentShape(.rect)
            .geometryGroup()
            .sensoryFeedback(.selection, trigger: isSelected)
            .onTapGesture
            {
                tagManager.toggleTag(tag: tag)
            }
    }
    
    var isSelected: Bool
    {
        return tagManager.allTags.first(where: { $0.id == tag.id })?.isSelected ?? false
    }
}

extension FilterButton
{
    var filterLabel: some View
    {
        Label
        {
            Text(tag.title)
                .fontWeight(.medium)
        }
        icon:
        {
            Image(systemName: tag.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .fontWeight(.semibold)
                .padding(.horizontal, -2)
        }
        .font(.subheadline)
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .foregroundStyle(.black)
    }
    
    var filterBackground: some View
    {
        ZStack
        {
            if tag.isSelected
            {
                Color.blue
                    .brightness(0.3)
                    .saturation(0.4)
            }
            else
            {
                Color.white
            }
        }
        .opacity(0.9)
        .clipShape(.capsule)
        .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
    }
}

#Preview
{
    ActivityPickerScreen()
}
