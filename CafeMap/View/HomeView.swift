//
//  HomeView.swift
//  CafeMap
//
//  Created by 정건호 on 4/4/25.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            if let region = viewModel.currentRegion {
                CustomMapView(
                    region: region,
                    places: viewModel.places,
                    onAnnotationTap: { place in
                        Task {
                            await viewModel.fetchDetailPlace(id: place.id)
                        }
                    }
                )
                .ignoresSafeArea(edges: .top)
            }
        }
        .onReceive(locationManager.$currentLocation.compactMap { $0 }) { location in
            Task {
                await viewModel.fetchNearbyPlaces(at: location)
            }
        }
    }
}

#Preview {
    HomeView()
}
