//
//  DateExtension.swift
//  CafeMap
//
//  Created by 정건호 on 5/25/25.
//

import Foundation

extension Date {
    var toDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }
}
