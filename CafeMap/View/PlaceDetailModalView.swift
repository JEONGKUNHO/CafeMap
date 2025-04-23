//
//  PlaceDetailModalView.swift
//  CafeMap
//
//  Created by 정건호 on 4/19/25.
//

import SwiftUI
import GooglePlacesSwift

struct PlaceDetailModalView: View {
    let place: Place
    @Binding var isExpanded: Bool
    @Binding var showModal: Bool
    
    var body: some View {
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
            
            // 口コミ
            HStack(alignment: .bottom, spacing: 0) {
                if let rating = place.rating {
                    Text("⭐️").padding(.trailing, 4)
                    Text(String(format: "%.1f", rating)).padding(.trailing, 2)
                    Text("(\(place.numberOfUserRatings))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            
            // ボタン
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Spacer().frame(width: 0)
                    
                    if let phone = place.internationalPhoneNumber,
                       let url = URL(string: "tel://\(phone)") {
                        ActionButton(icon: "phone.fill", text: "電話", color: .blue) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    if let url = place.websiteURL {
                        ActionButton(icon: "safari.fill", text: "Webサイト", color: .blue) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    ActionButton(icon: "square.and.pencil", text: "レビューを書く", color: .blue) {
                        print("レビューを書く tapped")
                    }
                    
                    ActionButton(icon: "camera.fill", text: "写真登録", color: .blue) {
                        print("写真登録　tapped")
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
                            Text("営業時間")
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
            Spacer()
        }
    }
}
