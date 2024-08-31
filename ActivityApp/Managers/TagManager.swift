import SwiftUI
import MapKit

@Observable class TagManager
{
    weak var mapManager: MapManager?
    
    var allTags: [OSMTag] = OSMTag.allTags
    var selectedTags: [OSMTag] { allTags.filter({ $0.isSelected }) }
    var currentTag: OSMTag?
    
    /// Toggles the selection state of a tag.
    ///
    /// This will cause ``HorizontalTagPicker`` to be re-ordered and ``TagMap`` to load or remove the tag's map markers.
    /// - Parameter tag: The tag to toggle.
    public func toggleTag(tag: OSMTag)
    {
        // find the tapped tag in allTags
        guard let index = allTags.firstIndex(of: tag) else
        {
            return TagManagerError.print(.ToggleTagButtonNotFoundError)
        }
        
        // toggle the tag's isSelected property
        allTags[index].isSelected.toggle()
        let tag = allTags[index]
        
        // sort tags based on isSelected
        sortTags()
        
        // load or remove map markers for that tag
        mapManager?.toggleMapMarkers(for: tag)
    }
    
    public func scrollToFirst()
    {
        guard let currentTag else { return }
        guard currentTag != self.allTags.first else { return }
        
        withAnimation(.easeOut(duration: 10))
        {
            self.currentTag = self.allTags.first
        }
    }
    
    private func sortTags()
    {
        withAnimation(.spring(duration: 0.6))
        {
            self.allTags.sort { $0.isSelected && !$1.isSelected }
        }
    }
}

extension TagManager
{
    enum TagManagerError: String
    {
        case ToggleTagButtonNotFoundError
        
        static func print(_ error: TagManagerError)
        {
            switch error
            {
                case .ToggleTagButtonNotFoundError: Swift.print("[error] TagManager\(error.rawValue): Tag was not found.")
            }
        }
    }
}
