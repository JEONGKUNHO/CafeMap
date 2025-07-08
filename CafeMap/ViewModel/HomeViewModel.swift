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
import FirebaseCore
import FirebaseFirestore
import RealmSwift

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var places: [CafePlace] = []
    @Published var currentRegion: MKCoordinateRegion?
    @Published var placeDetail: Place? = nil
    @Published var cafeReviews: [CafeReview] = []
    
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
            regionCode: NSLocalizedString("region", comment: String())
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
    
    func fetchDetailPlace(id placeID: String, from type: TabViewType = .home) async {
        let fetchPlaceRequest = FetchPlaceRequest(
            placeID: placeID,
            placeProperties: [.all]
        )
        
        let result = await PlacesClient.shared.fetchPlace(with: fetchPlaceRequest)
        
        switch result {
        case .success(let fetchedPlace):
            placeDetail = fetchedPlace
            if type == .bookmark {
                places.removeAll()
                if let place = placeDetail?.asCafePlace() {
                    places.append(place)
                }
            }
        case .failure(let error):
            print("Place Detail API Error: \(error)")
        }
    }
    
    func fetchPlaceReview(id placeID: String) async {
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db
                .collection("CafeReviews")
                .document(placeID)
                .collection("reviews")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let reviews = try snapshot.documents.compactMap {
                try $0.data(as: CafeReview.self)
            }
            
            self.cafeReviews = reviews
        } catch {
            print(error)
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
    
    func saveReview(placeID: String, reviewText: String, serviceRating: Int, cleanlinessRating: Int, tasteRating: Int) async throws {
        let newDocRef = Firestore.firestore()
             .collection("CafeReviews")
             .document(placeID)
             .collection("reviews")
        
        let reviewData: [String: Any] = [
            "id": newDocRef.document().documentID,
            "reviewText": reviewText,
            "serviceRating": serviceRating,
            "cleanlinessRating": cleanlinessRating,
            "tasteRating": tasteRating,
            "createdAt": Date().toDateString
        ]
        
        try await newDocRef.addDocument(data: reviewData)
    }
    
    //　Realm関連関数
    func isBookmarked(placeID: String) -> Bool {
        let realm = try! Realm()
        return realm.object(ofType: Bookmark.self, forPrimaryKey: placeID) != nil
    }
    
    func addBookmark(placeID: String, title: String) {
        let realm = try! Realm()
        let bookmark = Bookmark()
        bookmark.id = placeID
        bookmark.title = title
        try! realm.write {
            realm.add(bookmark)
        }
    }
    
    func removeBookmark(placeID: String) {
        let realm = try! Realm()
        if let existing = realm.object(ofType: Bookmark.self, forPrimaryKey: placeID) {
            try! realm.write {
                realm.delete(existing)
            }
        }
    }
}
