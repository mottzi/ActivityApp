import SwiftUI
import MapKit

struct CategoryPicker: View
{
    @Bindable var categoryManager: CategoryManager

    var body: some View
    {
        ScrollView(.horizontal)
        {
            HStack
            {
                ForEach(categoryManager.allCategories, id: \.self)
                { category in
                    CategoryButton(category: category, categoryManager: categoryManager)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $categoryManager.currentCategory, anchor: .leading)
        .scrollIndicators(.never)
        .contentMargins(.horizontal, 16)
        .onAppear
        {
            categoryManager.currentCategory = categoryManager.allCategories.last
            categoryManager.currentCategory = categoryManager.allCategories.first
        }
    }
}

#Preview
{
    ActivityPickerScreen()
}
