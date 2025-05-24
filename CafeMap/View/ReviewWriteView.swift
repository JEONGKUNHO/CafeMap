//
//  ReviewWriteView.swift
//  CafeMap
//
//  Created by 정건호 on 5/14/25.
//

import SwiftUI

struct ReviewWriteView: View {
    @Environment(\.dismiss) private var dismiss

    let viewModel: HomeViewModel
    let placeID: String
    @State private var serviceRating: Int = 0
    @State private var cleanlinessRating: Int = 0
    @State private var tasteRating: Int = 0
    @State private var reviewText: String = String()
    @State private var showError: Bool = false
    @State private var errorMessage: String = String()

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            HStack {
                Text("レビュー")
                    .font(.title2)
                    .bold()
                Spacer()
                Image(systemName: "xmark")
                    .font(.title2)
                    .onTapGesture {
                        dismiss()
                    }
            }

            TextField("レビューを記入してください", text: $reviewText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5, reservesSpace: true)

            VStack(alignment: .leading, spacing: 12) {
                RatingView(title: "サービス", rating: $serviceRating)
                RatingView(title: "清潔度", rating: $cleanlinessRating)
                RatingView(title: "味", rating: $tasteRating)
            }
            
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

            Spacer()

            Button(action: {
                Task {
                    if serviceRating == 0 || cleanlinessRating == 0 || tasteRating == 0 {
                        errorMessage = "すべての項目に星をつけてください"
                        showError = true
                    } else {
                        do {
                            try await viewModel.saveReview(
                                placeID: placeID,
                                reviewText: reviewText,
                                serviceRating: serviceRating,
                                cleanlinessRating: cleanlinessRating,
                                tasteRating: tasteRating
                            )
                            dismiss()
                        } catch {
                            errorMessage = "DBエラーが発生しました"
                            showError = true
                        }
                    }
                }
            }) {
                Text("作成する")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}
