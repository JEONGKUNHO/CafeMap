//
//  ContentView.swift
//  CafeMap
//
//  Created by 정건호 on 4/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("ホーム", systemImage: "house") {
                HomeView()
            }
            Tab("ブックマーク", systemImage: "bookmark") {
                BookMarkView()
            }
            Tab("マイページ", systemImage: "person") {
                MyPageView()
            }
        }
    }
}

#Preview {
    ContentView()
}
