import SwiftUI

struct CategoryButton: View
{
    let category: MapCategory
    
    let categoryManager: CategoryManager
    
    var body: some View
    {
        categoryLabel
            .background { categoryBackground }
            .padding(.bottom, 14)
            .padding(.bottom, 30)
            .contentShape(.rect)
            .geometryGroup()
            .sensoryFeedback(.selection, trigger: isSelected)
            .onTapGesture
            {
                categoryManager.toggleCategory(category: category)
            }
    }
    
    var isSelected: Bool
    {
        return categoryManager.allCategories.first(where: { $0.id == category.id })?.isSelected ?? false
    }
}

extension CategoryButton
{
    var categoryLabel: some View
    {
        Label
        {
            Text(category.title)
                .fontWeight(.medium)
        }
        icon:
        {
            Image(systemName: category.icon)
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
    
    var categoryBackground: some View
    {
        ZStack
        {
            if category.isSelected
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
