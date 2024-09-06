import SwiftUI
import MapKit

@Observable class CategoryManager
{
    @ObservationIgnored weak var mapManager: MapManager?
    
    var allCategories: [MapCategory] = MapCategory.allCategories
    var selectedCategories: [MapCategory] { allCategories.filter({ $0.isSelected }) }
    var currentCategory: MapCategory?
    
    /// Toggles the selection state of a category button.
    ///
    /// This will cause ``CategoryPicker`` to be re-ordered and ``CategoryMap`` to request (and add) or to remove the POI markers of the category.
    /// - Parameter category: The category button to toggle.
    public func toggleCategory(category: MapCategory)
    {
        // find the tapped tag in allTags
        guard let index = allCategories.firstIndex(of: category) else
        {
            return CategoryManagerError.print(.ToggleTagButtonNotFoundError)
        }
        
        // toggle the tag's isSelected property
        allCategories[index].isSelected.toggle()
        let category = allCategories[index]

        // sort tags based on isSelected
        sortCategories()
        
        // load or remove map markers for that tag
        mapManager?.toggleMapMarkers(for: category)
    }
    
    public func scrollToFirst()
    {
        guard let currentCategory else { return }
        guard currentCategory != self.allCategories.first else { return }
        
        withAnimation(.easeOut(duration: 10))
        {
            self.currentCategory = self.allCategories.first
        }
    }
    
    private func sortCategories()
    {
        withAnimation(.spring(duration: 0.6))
        {
            self.allCategories.sort { $0.isSelected && !$1.isSelected }
        }
    }
}

extension CategoryManager
{
    enum CategoryManagerError: String
    {
        case ToggleTagButtonNotFoundError
        
        static func print(_ error: CategoryManagerError)
        {
            switch error
            {
                case .ToggleTagButtonNotFoundError: Swift.print("[error] TagManager\(error.rawValue): Tag was not found.")
            }
        }
    }
}
