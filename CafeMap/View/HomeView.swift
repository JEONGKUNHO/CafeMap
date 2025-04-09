//
//  HomeView.swift
//  CafeMap
//
//  Created by 정건호 on 4/4/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        Text("ホーム")
            .onAppear {
                Task {
                    await viewModel.fetchNearbyPlaces()
                }
            }
    }
}

#Preview {
    HomeView()
}
