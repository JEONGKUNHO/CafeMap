//
//  ReviewCell.swift
//  CafeMap
//
//  Created by 정건호 on 5/25/25.
//

import SwiftUI

struct ReviewCell: View {
    let review: CafeReview

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🗣️ \(review.reviewText)")
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                Label("\(review.tasteRating)", systemImage: "fork.knife")
                Label("\(review.serviceRating)", systemImage: "person.2.fill")
                Label("\(review.cleanlinessRating)", systemImage: "sparkles")
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Text(review.createdAt)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
