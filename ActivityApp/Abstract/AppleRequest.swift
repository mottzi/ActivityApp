import SwiftUI
import MapKit

struct MKMapTagItem: Identifiable
{
    let id = UUID()
    let mapItem: MKMapItem
    let tag: MapFilter
}

class AppleRequest
{
    var tag: MapFilter
    var region: MKCoordinateRegion
    
    init(for tag: MapFilter, region: MKCoordinateRegion)
    {
        self.tag = tag
        self.region = region
    }
    
    func start() async -> [MKMapTagItem]?
    {
        guard let category = tag.apple else { return nil }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = tag.title
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: category)
        request.region = region
        
        guard let response = try? await MKLocalSearch(request: request).start() else { return nil }
        
        let result = response.mapItems.filter({ region.contains($0.placemark.coordinate) })
        
        let taggedResult = result.map { MKMapTagItem(mapItem: $0, tag: tag) }
        
        guard !taggedResult.isEmpty else { return nil }
        
        return taggedResult
    }
}
