import SwiftUI
import Combine
import MapKit

struct MapList: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var selectedPlace: MKMapItem? = nil
    var others: [MKMapItem]
    @Binding var targetLocation: CLLocationCoordinate2D?
    @Binding var targetName: String
    
    var body: some View {
        ZStack {
            Map(selection: $selectedPlace) {
                ForEach(others, id: \.self) { place in
                    Marker(item: place)
                        .tag(place)
                }
            }
            .onChange(of: selectedPlace) { _, newPlace in
                guard let newPlace else { return }

                //if 
                targetLocation = newPlace.location.coordinate
                targetName = newPlace.name ?? "NOTHING"
            }
            .navigationTitle(targetName)
            .toolbar {
                
                ToolbarItem {
                    Button {
                        openBusinessProfile(targetName)
                    } label: {
                        Image(systemName: "arrow.up.right.square")
                    }
                }
            }

        }
    }
    
}
