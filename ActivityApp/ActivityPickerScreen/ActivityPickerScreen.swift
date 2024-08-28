import SwiftUI
import MapKit

struct ActivityPickerScreen: View
{
    @State private var tagManager: TagManager
    @State private var mapManager: MapManager
    
    @MainActor
    init()
    {
        let tagManager = TagManager()
        _tagManager = State(initialValue: tagManager)
        _mapManager = State(initialValue: MapManager(tagManager: tagManager))
    }
    
    var body: some View
    {
        TagMap(mapManager: $mapManager)
            .overlay(alignment: .top)
            {
                VStack(spacing: 0)
                {
                    SearchBar()
                    HorizontalTagPicker(tagManager: $tagManager)
                }
                .padding(.top, 6)
            }
    }
}

#Preview
{
    ActivityPickerScreen()
}
