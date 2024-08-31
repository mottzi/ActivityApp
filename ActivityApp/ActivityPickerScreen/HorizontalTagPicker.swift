import SwiftUI
import MapKit

struct HorizontalTagPicker: View
{
    @Bindable var tagManager: TagManager

    var body: some View
    {

        ScrollView(.horizontal)
        {
            HStack
            {
                ForEach(tagManager.allTags, id: \.self)
                { tag in
                    TagButton(tag: tag, tagManager: tagManager)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $tagManager.currentTag, anchor: .leading)
        .scrollIndicators(.never)
        .contentMargins(.horizontal, 16)
        .onAppear
        {
            tagManager.currentTag = tagManager.allTags.last
            tagManager.currentTag = tagManager.allTags.first
        }
    }
}

#Preview
{
    ActivityPickerScreen()
}
