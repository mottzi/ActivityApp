import SwiftUI
import MapKit

@Observable class AppManager
{
    @ObservationIgnored var tagManager: TagManager
    @ObservationIgnored var mapManager: MapManager
    
    init(tagManager: TagManager, mapManager: MapManager) 
    {
        self.tagManager = tagManager
        self.mapManager = mapManager
    }
}

struct ActivityPickerScreen: View
{
    @State private var appManager: AppManager
    
    init()
    {
        let tagManager = TagManager()
        let mapManager = MapManager()
        
        _appManager = State(initialValue: .init(tagManager: tagManager, mapManager: mapManager))
        
        tagManager.appManager = appManager
        mapManager.appManager = appManager
    }
    
    var body: some View
    {
        TagMap()
            .overlay(alignment: .top)
            {
                VStack(spacing: 0)
                {
                    SearchBar()
                    HorizontalTagPicker()
                }
                .padding(.top, 6)
            }
            .environment(appManager)
    }
}

#Preview
{
    ActivityPickerScreen()
}
