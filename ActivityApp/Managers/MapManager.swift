import SwiftUI
import MapKit

@Observable class MapManager
{    
    @ObservationIgnored let tagManager: TagManager
    
    @ObservationIgnored var position: MapCameraPosition = .userLocation(fallback: .automatic)
//    var camera: MapCamera?
    @ObservationIgnored var region: MKCoordinateRegion?
    
    var searchResults: [MKMapItem] = []
    
    let locationManager = CLLocationManager()
    
    init(tagManager: TagManager)
    {
        self.tagManager = tagManager
        
        self.requestAuthorization()
    }
    
//    func updateCamera(_ camera: MapCamera)
//    {
//        self.camera = camera
//    }
    
    func requestAuthorization()
    {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func resetToUserLocation()
    {
        withAnimation { self.position = .userLocation(fallback: .automatic) }
    }
    
//    func onChangeSelectedTags(_ allTags: [OSMTag])
//    {
//        //searchItems(tags: allTags.filter( { $0.isSelected } ))
//        
//        print("[")
//        for e in allTags.filter({ $0.isSelected })
//        {
//            print("     \(e.name).isSelected = \(e.isSelected)")
//        }
//        print("],")
//    }
    
//    private func searchItems(tags: [OSMTag])
//    {
//        if tags.isEmpty
//        {
//            searchResults = []
//            return
//        }
//        
//        let tag = tags[0]
//        
//        guard let category = tag.category else { return }
//        guard let region else { return }
//        
//        print("2")
//
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = tag.name
//        request.resultTypes = .pointOfInterest
//        request.pointOfInterestFilter = .init(including: category)
//        request.region = region
//
//        print("3")
//
//        Task
//        {
//            guard let response = try? await MKLocalSearch(request: request).start()
//            else 
//            {
//                DispatchQueue.main.async
//                {
//                    self.searchResults = []
//                }
//                
//                return
//            }
//
//            DispatchQueue.main.async
//            {
////                withAnimation
////                {
//                    self.searchResults = response.mapItems.filter({ region.contains($0.placemark.coordinate)})
//                    
//                    if self.searchResults.isEmpty
//                    {
//                        self.position = .userLocation(fallback: .automatic)
//                    }
//                    else
//                    {
//                        self.position = .automatic
//                    }
////                }
//                
//                print("\(self.searchResults.count) items found.")
//            }
//            
//        }
//    }
}

extension MKCoordinateRegion 
{
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool 
    {
        let latDelta = self.span.latitudeDelta / 2.0
        let lonDelta = self.span.longitudeDelta / 2.0
        
        let minLat = self.center.latitude - latDelta
        let maxLat = self.center.latitude + latDelta
        let minLon = self.center.longitude - lonDelta
        let maxLon = self.center.longitude + lonDelta
        
        return (minLat...maxLat).contains(coordinate.latitude) && (minLon...maxLon).contains(coordinate.longitude)
    }
}

//extension View
//{
//    @MainActor
//    func onChangeTagSelection(mapManager: MapManager) -> some View
//    {
//        self
//            .onChange(of: mapManager.tagManager.allTags)
//            { old, new in
//                guard old.count == new.count else { return }
//                
//                let oldDict = Dictionary(uniqueKeysWithValues: old.map { ($0.id, $0) })
//                let newDict = Dictionary(uniqueKeysWithValues: new.map { ($0.id, $0) })
//                
//                var difference = false
//                
//                for (id, oldTag) in oldDict
//                {
//                    guard let newTag = newDict[id] else { return }
//                    
//                    if oldTag.isSelected != newTag.isSelected
//                    {
//                        difference = true
//                        break
//                    }
//                }
//                
//                if difference
//                {
//                    mapManager.onChangeSelectedTags(new)
//                }
//            }
//    }
//}
