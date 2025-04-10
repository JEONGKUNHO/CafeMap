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
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
            
            BookMarkView()
                .tabItem {
                    Label("ブックマーク", systemImage: "bookmark")
                }
            
            MyPageView()
                .tabItem {
                    Label("マイページ", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView()
}
