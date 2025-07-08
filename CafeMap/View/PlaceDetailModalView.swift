//
//  PlaceDetailModalView.swift
//  CafeMap
//
//  Created by 정건호 on 4/19/25.
//

import SwiftUI
import GooglePlacesSwift

struct PlaceDetailModalView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject var viewModel: HomeViewModel
    let place: Place
    
    @Binding var showModal: Bool
    @State private var isExpanded: Bool = false
    @State private var showReviewWriteView = false
    @State private var isBookmarked: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // 店の名前
                HStack(alignment: .top, spacing: 12) {
                    Text(place.displayName ?? "")
                        .font(.system(size: 24, weight: .semibold))
                        .lineLimit(2)
                    Spacer()
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 24))
                        .onTapGesture {
                            showModal = false
                        }
                }
                .padding(.top, 18)
                .padding(.horizontal, 12)
                
                // 口コミ、ブックマーク
                HStack(alignment: .bottom, spacing: 0) {
                    if let rating = place.rating {
                        Text("⭐️").padding(.trailing, 4)
                        Text(String(format: "%.1f", rating)).padding(.trailing, 2)
                        Text("(\(place.numberOfUserRatings))")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            guard let id = place.placeID,
                                  let title = place.displayName else { return }
                            
                            if isBookmarked {
                                viewModel.removeBookmark(placeID: id)
                                isBookmarked = false
                            } else {
                                viewModel.addBookmark(placeID: id, title: title)
                                isBookmarked = true
                            }
                        }
                }
                .padding(.horizontal, 12)
                
                //　位置移動ボタン
                if router.selectedTab == .bookmark {
                    ActionButton(icon: "location.fill", text: "moveToLocation", color: .blue, isFullWidth: true) {
                        router.selectedTab = .home
                        router.selectedPlaceID = place.placeID
                        router.location = place.location
                        showModal = false
                    }
                    .padding(.horizontal, 12)
                }
                
                // ボタン
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Spacer().frame(width: 0)
                        
                        if let phone = place.internationalPhoneNumber,
                           let url = URL(string: "tel://\(phone)") {
                            ActionButton(icon: "phone.fill", text: "call", color: .blue) {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        if let url = place.websiteURL {
                            ActionButton(icon: "safari.fill", text: "website", color: .blue) {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        ActionButton(icon: "square.and.pencil", text: "writeReview", color: .blue) {
                            showReviewWriteView = true
                        }
                        Spacer().frame(width: 12)
                    }
                }
                
                // 営業時間
                if let openingHours = place.regularOpeningHours {
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                Text("operatingHours")
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.gray)
                                    .animation(nil, value: isExpanded) // 애니메이션 제거
                            }
                        }
                        
                        if isExpanded {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(openingHours.weekdayText, id: \.self) { dayText in
                                    Text(dayText)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.25).delay(0.1), value: isExpanded)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 12)
                }
                
                //　レビュー
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("review")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        Spacer()
                    }
                    
                    if viewModel.cafeReviews.isEmpty {
                        Text("emptyReview")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.cafeReviews) { review in
                                ReviewCell(review: review)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showReviewWriteView) {
            if let placeID = place.placeID {
                ReviewWriteView(viewModel: viewModel, placeID: placeID)
            }
        }
        .onAppear {
            if let id = place.placeID {
                isBookmarked = viewModel.isBookmarked(placeID: id)
            }
        }
    }
}
