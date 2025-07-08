//
//  RatingView.swift
//  CafeMap
//
//  Created by 정건호 on 5/14/25.
//

import SwiftUI

struct RatingView: View {
    let title: String
    @Binding var rating: Int

    var body: some View {
        HStack {
            Text(NSLocalizedString(title, comment: String()))
                .frame(width: 80, alignment: .leading)
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .onTapGesture {
                        rating = index
                    }
            }
        }
    }
}
