import SwiftUI
import MapKit

struct ActivityPickerScreen: View
{
    @State private var categoryManager: CategoryManager
    @State private var mapManager: MapManager
    
    var body: some View
    {
        CategoryMap(mapManager: mapManager)
            .overlay(alignment: .top)
            {
                VStack(spacing: 0)
                {
                    SearchBar()
                    CategoryPicker(tagManager: categoryManager)
                }
                .padding(.top, 6)
            }
    }
    
    init()
    {
        let categoryManager = CategoryManager()
        let mapManager = MapManager()
        
        categoryManager.mapManager = mapManager
        mapManager.categoryManager = categoryManager
        
        _categoryManager = State(initialValue: categoryManager)
        _mapManager = State(initialValue: mapManager)
    }
}

#Preview
{
    ActivityPickerScreen()
}
