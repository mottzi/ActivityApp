import SwiftUI
import MapKit

struct ActivityPickerScreen: View
{
    @State private var filterManager: FilterManager
    @State private var mapManager: MapManager
    
    var body: some View
    {
        FilterMap(mapManager: mapManager)
            .overlay(alignment: .top)
            {
                VStack(spacing: 0)
                {
                    SearchBar()
                    FilterPicker(tagManager: filterManager)
                }
                .padding(.top, 6)
            }
    }
    
    init()
    {
        let filterManager = FilterManager()
        let mapManager = MapManager()
        
        filterManager.mapManager = mapManager
        mapManager.filterManager = filterManager
        
        _filterManager = State(initialValue: filterManager)
        _mapManager = State(initialValue: mapManager)
    }
}

#Preview
{
    ActivityPickerScreen()
}
