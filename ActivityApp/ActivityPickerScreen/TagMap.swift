import SwiftUI
import MapKit

struct TagMap: View
{
    @Namespace var mapScope
    
    @Binding var mapManager: MapManager
   
    var body: some View
    {
        Map(position: $mapManager.position, scope: mapScope)
        {
            UserAnnotation()
        }
        .onMapChange(mapManager: mapManager, mapManager.tagManager.resetCurrentTag)
        .onMapCameraChange(frequency: .continuous)
        {
            mapManager.camera = $0.camera
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

extension Map
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
