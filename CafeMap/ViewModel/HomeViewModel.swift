//
//  HomeViewModel.swift
//  CafeMap
//
//  Created by 정건호 on 4/9/25.
//

import Foundation
import CoreLocation
import GooglePlacesSwift

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var places: [Place] = []

    func fetchNearbyPlaces() async {
        let restriction = CircularCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.7765251, longitude: 139.8319541),
            radius: 500
        )

        let searchNearbyRequest = SearchNearbyRequest(
            locationRestriction: restriction,
            placeProperties: [ .displayName, .coordinate ],
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
            self.places = fetchedPlaces
        case .failure(let error):
            print(error)
        }
    }
}
