//
//  CafePlace.swift
//  CafeMap
//
//  Created by 정건호 on 4/9/25.
//

import CoreLocation

struct CafePlace: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let displayName: String
}
