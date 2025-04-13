//
//  DoubleExtension.swift
//  CafeMap
//
//  Created by 정건호 on 4/13/25.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
