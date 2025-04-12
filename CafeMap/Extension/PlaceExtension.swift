//
//  PlaceExtension.swift
//  CafeMap
//
//  Created by 정건호 on 4/9/25.
//

import GooglePlacesSwift

extension Place {
    func asCafePlace() -> CafePlace {
        return CafePlace(id: self.placeID ?? String(), coordinate: self.location, displayName: self.displayName ?? String())
    }
}
