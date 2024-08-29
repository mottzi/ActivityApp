import SwiftUI
import MapKit

struct TagMap: View
{
    @Environment(\.scenePhase) var scenePhase
    
    @Binding var mapManager: MapManager
    @Namespace var mapScope
    
    @State private var searchResults: [MKMapItem] = []
    
    var body: some View
    {
        Map(position: $mapManager.position, scope: mapScope)
        {
            UserAnnotation()
               
            let _ = Self._printChanges()
            
            ForEach(searchResults, id: \.self)
            { result in
                Marker(item: result)
            }
        }
        .onMapChange(mapManager: mapManager, mapManager.tagManager.scrollToFirst)
        .onMapCameraChange(frequency: .onEnd)
        {
            mapManager.region = $0.region
//            mapManager.camera = $0.camera
        }
//        .onAppear(perform: mapManager.requestAuthorization)
//         .onChangeTagSelection(mapManager: mapManager)
        .onChange(of: mapManager.tagManager.selectedTags)
        { oldTags, newTags in
            // if all tags are unselected, reset map
            guard newTags.count > 0 else { return /*resetMap()*/ }
            // if there is no coordinate region, reset map
            guard let region = self.mapManager.region else { return /*resetMap()*/ }
            
            // every search request appends to this array
            var filteredItems: [MKMapItem] = []
            
            // wait for all sub-requests to respond
            let group = DispatchGroup()
            for tag in newTags where tag.category != nil
            {
                // prepare sub-request
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = tag.name
                request.resultTypes = .pointOfInterest
                request.pointOfInterestFilter = MKPointOfInterestFilter(including: tag.category!)
                request.region = region
                
                group.enter()
                
                MKLocalSearch(request: request).start()
                { response, _ in
                    // fetch items from sub-request
                    if let response
                    {
                        let result = response.mapItems.filter({ region.contains($0.placemark.coordinate) })
                        filteredItems.append(contentsOf: result)
                    }
                    
                    group.leave()
                }
            }
            
            // all sub-requests have responded
            group.notify(queue: .main)
            {
                print("* Found '\(filteredItems.count)' items.")

                withAnimation
                {
                    // update state variable with new map items
                    searchResults = filteredItems
                    
                    // center map around user location if nothing was found
//                    if searchResults.isEmpty
//                    {
//                        mapManager.position = .userLocation(fallback: .automatic)
//                    }
//                    else // position map so every marker is visible
//                    {
//                        mapManager.position = .automatic
//                    }
                }
            }
        }
        .onChange(of: scenePhase)
        {
            guard scenePhase == .active else { return }
            
            mapManager.requestAuthorization()
            mapManager.resetToUserLocation()
        }
        .overlay(alignment: .bottomTrailing)
        {
            VStack
            {
                MapUserLocationButton(scope: mapScope)
                MapPitchToggle(scope: mapScope)
                MapCompass(scope: mapScope)
            }
            .padding(.trailing, 10)
            .buttonBorderShape(.circle)
            .shadow(color: .black.opacity(0.1), radius: 2, y: 2)
            .mapControlVisibility(.visible)
        }
        .overlay(alignment: .bottom)
        {
//            CoordinateCapsule(camera: mapManager.camera)
        }
        .ignoresSafeArea(.keyboard)
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .mapControls { }
        .mapScope(mapScope)
    }
    
    func resetMap()
    {
        DispatchQueue.main.async
        {
            withAnimation
            {
                // remove all map markers
                searchResults = []
                // reset map
                mapManager.position = .userLocation(fallback: .automatic)
            }
        }
    }
}



extension View
{
    @MainActor
    func onMapChange(mapManager: MapManager, _ action: @escaping () -> Void) -> some View
    {
        self
            .onChange(of: mapManager.position.followsUserLocation, action)
            .onChange(of: mapManager.position.followsUserHeading, action)
            .onMapCameraChange(frequency: .continuous)
            {
                if mapManager.position.positionedByUser { action() }
            }
    }
}

struct CoordinateCapsule: View
{
    @Environment(\.colorScheme) var scheme
    
    let camera: MapCamera?
        
    var body: some View
    {
        Text(camera?.centerCoordinate != nil && camera?.distance != nil ? "\(camera!.centerCoordinate.latitude) | \(camera!.centerCoordinate.longitude) | \(camera!.distance.string) m" : "nothing")
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .foregroundStyle(.black)
            .font(.caption)
            .fontWeight(.medium)
            .fontDesign(.monospaced)
            .background(.white.opacity(scheme == .dark ? 0.5 : 0.7), in: .capsule)
            .padding(.bottom, 63)
    }
}

#Preview
{
    ActivityPickerScreen()
}
