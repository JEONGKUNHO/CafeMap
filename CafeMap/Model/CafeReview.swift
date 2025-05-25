//
//  CafeReview.swift
//  CafeMap
//
//  Created by 정건호 on 5/25/25.
//

import Foundation

struct CafeReview: Identifiable, Decodable {
    let id: String
    let reviewText: String
    let serviceRating: Int
    let cleanlinessRating: Int
    let tasteRating: Int
    let createdAt: String
}
