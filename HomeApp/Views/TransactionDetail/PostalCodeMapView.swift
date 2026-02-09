//
//  PostalCodeMapView.swift
//  HomeApp
//
//  Family Expense Tracker - Location Map Component
//

import SwiftUI
import MapKit

struct PostalCodeMapView: View {
    let postalCode: String
    
    @State private var position: MapCameraPosition = .automatic
    @State private var coordinate: CLLocationCoordinate2D?
    
    var body: some View {
        Map(position: $position) {
            if let coordinate {
                Marker("", coordinate: coordinate)
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .disabled(true) // Prevent map interaction, tap opens Maps app instead
        .overlay {
            // Invisible button to capture taps
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    openInMaps()
                }
        }
        .task {
            await geocodePostalCode()
        }
    }
    
    private func geocodePostalCode() async {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(postalCode)
            if let location = placemarks.first?.location?.coordinate {
                coordinate = location
                position = .region(MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            }
        } catch {
            // Geocoding failed, map will be empty
        }
    }
    
    private func openInMaps() {
        guard let coordinate else { return }
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = postalCode
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        ])
    }
}

#Preview {
    PostalCodeMapView(postalCode: "M5V 1J2")
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
}
