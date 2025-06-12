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
                    }
                    .onDelete(perform: deleteBookmark)
                }
            }
            .navigationTitle("ブックマーク")
        }
    }
    
    private func deleteBookmark(at offsets: IndexSet) {
        let realm = try! Realm()
        
        let itemsToDelete = offsets.map { bookmarks[$0] }
        
        try? realm.write {
            itemsToDelete.forEach { item in
                if let thawedItem = item.thaw() {
                    realm.delete(thawedItem)
                }
            }
        }
    }
}

#Preview {
    BookMarkView()
}
