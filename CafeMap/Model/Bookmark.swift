//
//  Bookmark.swift
//  CafeMap
//
//  Created by 정건호 on 6/9/25.
//

import Foundation
import MapKit
import RealmSwift

class Bookmark: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String = String()
    @Persisted var date: Date = Date()
}
