import SwiftUI
import MapKit

struct CategoryPicker: View
{
    @Bindable var tagManager: CategoryManager

    var body: some View
    {
        ScrollView(.horizontal)
        {
            HStack
            {
                ForEach(tagManager.allCategories, id: \.self)
                { tag in
                    CategoryButton(tag: tag, tagManager: tagManager)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $tagManager.currentCategory, anchor: .leading)
        .scrollIndicators(.never)
        .contentMargins(.horizontal, 16)
        .onAppear
        {
            tagManager.currentCategory = tagManager.allCategories.last
            tagManager.currentCategory = tagManager.allCategories.first
        }
    }
}

#Preview
{
    ActivityPickerScreen()
}
