//
//  BookMarkView.swift
//  CafeMap
//
//  Created by 정건호 on 4/4/25.
//

import SwiftUI
import RealmSwift

struct BookMarkView: View {
    @ObservedResults(Bookmark.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var bookmarks
    @StateObject private var viewModel = HomeViewModel()
    @State private var showPlaceModal = false
    @State private var selectedBookmark: Bookmark?

    var body: some View {
        NavigationView {
            List {
                if bookmarks.isEmpty {
                    Text("ブックマークがありません")
                        .foregroundColor(.gray)
                } else {
                    ForEach(bookmarks) { bookmark in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bookmark.title)
                                .font(.headline)
                            Text(bookmark.date.toDateString)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .onTapGesture {
                            Task {
                                await viewModel.fetchDetailPlace(id: bookmark.id)
                                await viewModel.fetchPlaceReview(id: bookmark.id)
                                selectedBookmark = bookmark
                                showPlaceModal = true
                            }
                        }
                    }
                    .onDelete(perform: deleteBookmark)
                }
            }
            .navigationTitle("ブックマーク")
        }
        .sheet(isPresented: $showPlaceModal) {
            if let place = viewModel.placeDetail {
                PlaceDetailModalView(
                    viewModel: viewModel,
                    place: place,
                    showModal: $showPlaceModal
                )
                .presentationDetents([.medium, .fraction(0.999)])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private func deleteBookmark(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { bookmarks[$0] }
        itemsToDelete.forEach { item in
            viewModel.removeBookmark(placeID: item.id)
        }
    }
}
