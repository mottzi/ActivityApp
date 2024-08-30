import SwiftUI
import MapKit

struct HorizontalTagPicker: View
{
    @Environment(AppManager.self) var appManager

    var body: some View
    {
        @Bindable var appManager = appManager

        ScrollView(.horizontal)
        {
            HStack
            {
                ForEach(appManager.tagManager.allTags, id: \.self)
                { tag in
                    TagButton(tag: tag)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $appManager.tagManager.currentTag, anchor: .leading)
        .scrollIndicators(.never)
        .contentMargins(.horizontal, 16)
        .onAppear
        {
            appManager.tagManager.currentTag = appManager.tagManager.allTags.last
            appManager.tagManager.currentTag = appManager.tagManager.allTags.first
        }
    }
}

#Preview
{
    ActivityPickerScreen()
}
