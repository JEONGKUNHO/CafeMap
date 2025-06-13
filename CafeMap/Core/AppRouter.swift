//
//  AppRouter.swift
//  CafeMap
//
//  Created by 정건호 on 6/12/25.
//

import Foundation
import CoreLocation

class AppRouter: ObservableObject {
    @Published var selectedTab: TabViewType = .home
    @Published var selectedPlaceID: String? = nil
    @Published var location: CLLocationCoordinate2D? = nil
}
