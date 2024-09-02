import SwiftUI
import MapKit

struct CategoryMap: View
{
    @Environment(\.scenePhase) var scenePhase
    @Namespace var mapScope
    
    @Bindable var mapManager: MapManager
        
    var body: some View
    {
        Map(position: $mapManager.position, scope: mapScope)
        {
            UserAnnotation()
                           
            ForEach(mapManager.appleSearchResults)
            { result in
                Marker(item: result.mapItem)
            }
            
            ForEach(mapManager.osmSearchResults)
            { result in
                Marker(result.name, coordinate: result.coordinate)
            }
        }
        .onMapChange(mapManager: mapManager, mapManager.categoryManager?.scrollToFirst)
        .onMapCameraChange(frequency: .onEnd)
        {
            mapManager.region = $0.region
        }
        .onAppear(perform: mapManager.requestAuthorization)
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
        // .overlay(alignment: .bottom)
        // {
        //     CoordinateCapsule(camera: mapManager.camera)
        // }
        .ignoresSafeArea(.keyboard)
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .mapControls { }
        .mapScope(mapScope)
    }
}

extension View
{
    @ViewBuilder
    func onMapChange(mapManager: MapManager, _ action: (() -> Void)?) -> some View
    {
        if let action
        {
            self
                .onChange(of: mapManager.position.followsUserLocation, action)
                .onChange(of: mapManager.position.followsUserHeading, action)
                .onMapCameraChange(frequency: .continuous)
                {
                    if mapManager.position.positionedByUser { action() }
                }
        }
        else
        {
            self
        }
    }
}

//struct CoordinateCapsule: View
//{
//    @Environment(\.colorScheme) var scheme
//    
//    let camera: MapCamera?
//        
//    var body: some View
//    {
//        Text(camera?.centerCoordinate != nil && camera?.distance != nil ? "\(camera!.centerCoordinate.latitude) | \(camera!.centerCoordinate.longitude) | \(camera!.distance.string) m" : "nothing")
//            .padding(.horizontal, 9)
//            .padding(.vertical, 5)
//            .foregroundStyle(.black)
//            .font(.caption)
//            .fontWeight(.medium)
//            .fontDesign(.monospaced)
//            .background(.white.opacity(scheme == .dark ? 0.5 : 0.7), in: .capsule)
//            .padding(.bottom, 63)
//    }
//}

#Preview
{
    ActivityPickerScreen()
}
