//
//  ContentView.swift
//  CafeMap
//
//  Created by 정건호 on 4/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var router = AppRouter()
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tabItem {
                    Label("home", systemImage: "house")
                }
                .tag(TabViewType.home)
            
            BookMarkView()
                .tabItem {
                    Label("bookmark", systemImage: "bookmark")
                }
                .tag(TabViewType.bookmark)
            
            MyPageView()
                .tabItem {
                    Label("myPage", systemImage: "person")
                }
                .tag(TabViewType.myPage)
        }
        .environmentObject(router)
    }
}

#Preview {
    ContentView()
}

enum TabViewType: Int, Hashable {
    case home = 0
    case bookmark = 1
    case myPage = 2
}
