import SwiftUI
import MapKit

struct TagMap: View
{
    @Environment(\.scenePhase) var scenePhase
    @Environment(AppManager.self) var appManager
        
    @Namespace var mapScope
        
    var body: some View
    {
        @Bindable var appManager = appManager
        
        Map(position: $appManager.mapManager.position, scope: mapScope)
        {
            UserAnnotation()
               
            let _ = Self._printChanges()
            
            ForEach(appManager.mapManager.searchResults, id: \.self.mapItem)
            { result in
                Marker(item: result.mapItem)
            }
        }
        .onMapChange(mapManager: appManager.mapManager, appManager.tagManager.scrollToFirst)
        .onMapCameraChange(frequency: .onEnd)
        {
            appManager.mapManager.region = $0.region
//            mapManager.camera = $0.camera
        }
        .onAppear(perform: appManager.mapManager.requestAuthorization)
        .onChange(of: scenePhase)
        {
            guard scenePhase == .active else { return }
            
            appManager.mapManager.requestAuthorization()
            appManager.mapManager.resetToUserLocation()
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
//        .overlay(alignment: .bottom)
//        {
//            CoordinateCapsule(camera: mapManager.camera)
//        }
        .ignoresSafeArea(.keyboard)
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
        .mapControls { }
        .mapScope(mapScope)
    }
}

extension View
{
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
