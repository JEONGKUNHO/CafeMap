//
//  HomeViewModel.swift
//  CafeMap
//
//  Created by 정건호 on 4/9/25.
//

import Foundation
import CoreLocation
import GooglePlacesSwift
import MapKit

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var places: [CafePlace] = []
    @Published var currentRegion: MKCoordinateRegion?

    func fetchNearbyPlaces(at coordinate: CLLocationCoordinate2D) async {
        let restriction = CircularCoordinateRegion(
            center: coordinate,
            radius: 500
        )

        let searchNearbyRequest = SearchNearbyRequest(
            locationRestriction: restriction,
            placeProperties: [.placeID, .coordinate],
            includedPrimaryTypes: [
                PlaceType(rawValue: "cafe"),
                PlaceType(rawValue: "coffee_shop"),
                PlaceType(rawValue: "cafeteria"),
                PlaceType(rawValue: "hamburger_restaurant"),
                PlaceType(rawValue: "fast_food_restaurant")
            ],
            regionCode: "jp"
        )

        let result = await PlacesClient.shared.searchNearby(with: searchNearbyRequest)

        switch result {
        case .success(let fetchedPlaces):
            self.places = fetchedPlaces.compactMap { $0.asCafePlace() }
            self.currentRegion = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        case .failure(let error):
            print("Places API Error: \(error)")
        }
    }
}
