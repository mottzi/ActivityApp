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
                        
            ForEach(searchResults, id: \.self)
            { result in
                Marker(item: result)
            }
        }
        .onMapChange(mapManager: mapManager, mapManager.tagManager.scrollToFirst)
        .onMapCameraChange(frequency: .continuous) 
        {
            mapManager.region = $0.region
        }
        .onMapCameraChange(frequency: .onEnd)
        {
            mapManager.updateCamera($0.camera)
        }
        .onAppear(perform: mapManager.requestAuthorization)
        // .onChangeTagSelection(mapManager: mapManager)
        .onChange(of: mapManager.tagManager.selectedTags)
        { old, new in
            print("change of tag selection detected [\(new.map { $0.name }.joined(separator: ", "))]")
             
            // make sure we have a valid map region,
            guard let region = self.mapManager.region,
                  let tag = new.first,
                  let category = tag.category
            else
            {
                withAnimation
                {
                    // reset map
                    searchResults = []
                    mapManager.position = .userLocation(fallback: .automatic)
                }
                print("region, tag, or category invalid")
                return
            }
                                            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = tag.name
            request.resultTypes = .pointOfInterest
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: category)
            request.region = region
            
            Task
            {
                guard let response = try? await MKLocalSearch(request: request).start() else
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
                    
                    print("no response")
                    return
                }
                
                DispatchQueue.main.async
                {
                    withAnimation
                    {
                        // only add found items if they are inside the current map coordinate region
                        searchResults = response.mapItems.filter({ region.contains($0.placemark.coordinate) })
                        
                        if searchResults.isEmpty
                        {
                            // center map around user location
                            mapManager.position = .userLocation(fallback: .automatic)
                        }
                        else
                        {
                            // position map so every marker is visible
                            mapManager.position = .automatic
                        }
                        
                        print("showing results with animation")
                    }
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
            CoordinateCapsule(camera: mapManager.camera)
        }
        .ignoresSafeArea(.keyboard)
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .mapControls { }
        .mapScope(mapScope)
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
