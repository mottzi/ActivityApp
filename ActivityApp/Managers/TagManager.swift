import SwiftUI
import MapKit

struct MKMapTagItem: Hashable
{
    let mapItem: MKMapItem
    let tag: OSMTag
}

@Observable class TagManager
{
    @ObservationIgnored var appManager: AppManager? = nil
    
    var allTags: [OSMTag] = OSMTag.allTags
    var selectedTags: [OSMTag] { allTags.filter({ $0.isSelected }) }
    
    var currentTag: OSMTag?
    
    public func toggleTag(tag: OSMTag)
    {
        guard let index = allTags.firstIndex(of: tag) else
        {
            return TagManagerError.print(.ToggleTagButtonNotFoundError)
        }
        
        self.allTags[index].isSelected.toggle()
        
        if tag.category != nil && appManager?.mapManager.region != nil
        {
            if allTags[index].isSelected
            {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = tag.name
                request.resultTypes = .pointOfInterest
                request.pointOfInterestFilter = MKPointOfInterestFilter(including: tag.category!)
                request.region = (appManager?.mapManager.region)!

                MKLocalSearch(request: request).start()
                { response, _ in
                    if let response
                    {
                        let result = response.mapItems.filter({ (self.appManager?.mapManager.region)!.contains($0.placemark.coordinate) })
                        let convertedResult = result.map { MKMapTagItem(mapItem: $0, tag: tag) }
                        
                        withAnimation
                        {
                            self.appManager?.mapManager.searchResults.append(contentsOf: convertedResult)
                        }
                    }
                }
            }
            else
            {
                let filtered = self.appManager?.mapManager.searchResults.filter { return $0.tag.id != tag.id }
                
                self.appManager?.mapManager.searchResults = filtered ?? []
                
                if let items = self.appManager?.mapManager.searchResults
                {
                    for item in items
                    {
                        print("'\(String(describing: item.mapItem.name))', tag '\(item.tag.name)', category '\(String(describing: item.mapItem.pointOfInterestCategory))'")
                    }
                }
            }
        }
        
        self.sortTags()
    }
    
    public func sortTags()
    {
        withAnimation(.spring(duration: 0.6))
        {
            self.allTags.sort { $0.isSelected && !$1.isSelected }
        }
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
