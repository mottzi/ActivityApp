import SwiftUI
import MapKit

struct ActivityPickerScreen: View
{
    @State private var tagManager: TagManager
    @State private var mapManager: MapManager
    
    var body: some View
    {
        TagMap(mapManager: mapManager)
            .overlay(alignment: .top)
            {
                VStack(spacing: 0)
                {
                    SearchBar()
                    HorizontalTagPicker(tagManager: tagManager)
                }
                .padding(.top, 6)
            }
    }
    
    init()
    {
        let tagManager = TagManager()
        let mapManager = MapManager()
        
        tagManager.mapManager = mapManager
        mapManager.tagManager = tagManager
        
        _tagManager = State(initialValue: tagManager)
        _mapManager = State(initialValue: mapManager)
    }
}

#Preview
{
    ActivityPickerScreen()
}
