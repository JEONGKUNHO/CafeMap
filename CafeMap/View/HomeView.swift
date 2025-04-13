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
    @State private var currentLocation: CLLocationCoordinate2D?
    @State private var isMapDragged: Bool = false
    @State private var reloadButtonClicked = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let region = viewModel.currentRegion {
                CustomMapView(
                    region: region,
                    places: viewModel.places,
                    onAnnotationTap: { place in
                        Task {
                            await viewModel.fetchDetailPlace(id: place.id)
                        }
                    },
                    currentLocation: $currentLocation,
                    isMapDragged: $isMapDragged,
                    reloadButtonClicked: $reloadButtonClicked
                )
                .ignoresSafeArea(edges: .top)
                
                if isMapDragged {
                    Button("このエリアを検索") {
                        Task {
                            reloadButtonClicked = true
                            if let currentLocation = currentLocation {
                                await viewModel.fetchNearbyPlaces(at: currentLocation)
                                isMapDragged = false
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(25)
                    .padding(.bottom, 16)
                }
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
