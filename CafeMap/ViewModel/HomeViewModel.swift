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
    @Published var placeDetail: Place? = nil
    
    func fetchNearbyPlaces(at coordinate: CLLocationCoordinate2D) async {
        let restriction = CircularCoordinateRegion(
            center: coordinate,
            radius: 500
        )
        
        let searchNearbyRequest = SearchNearbyRequest(
            locationRestriction: restriction,
            placeProperties: [.placeID, .coordinate, .displayName],
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
    
    func fetchDetailPlace(id placeID: String) async {
        let fetchPlaceRequest = FetchPlaceRequest(
            placeID: placeID,
            placeProperties: [.all]
        )
        
        let result = await PlacesClient.shared.fetchPlace(with: fetchPlaceRequest)
        
        switch result {
        case .success(let fetchedPlace):
            print(fetchedPlace)
            placeDetail = fetchedPlace
        case .failure(let error):
            print("Place Detail API Error: \(error)")
        }
    }
    
    func searchPlaces(keyword: String) async -> CLLocationCoordinate2D {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyword
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.publicTransport])
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            return response.boundingRegion.center
        } catch {
            print("検索エラー: \(error.localizedDescription)")
            return currentRegion?.center ?? CLLocationCoordinate2D()
        }
    }
}
