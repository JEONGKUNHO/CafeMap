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
    @State private var moveToUserLocation = false
    @State private var showPlaceModal = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let region = viewModel.currentRegion {
                CustomMapView(
                    region: region,
                    places: viewModel.places,
                    onAnnotationTap: { place in
                        Task {
                            await viewModel.fetchDetailPlace(id: place.id)
                            showPlaceModal = true
                        }
                    },
                    currentLocation: $currentLocation,
                    isMapDragged: $isMapDragged,
                    reloadButtonClicked: $reloadButtonClicked,
                    moveToUserLocation: $moveToUserLocation
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
                    
                    HStack {
                        Spacer()
                        Image(systemName: "location.fill")
                            .padding()
                            .foregroundStyle(Color.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .padding(12)
                            .onTapGesture {
                                moveToUserLocation = true
                            }
                    }
                }
            }
        }
        .onReceive(locationManager.$currentLocation.compactMap { $0 }) { location in
            Task {
                await viewModel.fetchNearbyPlaces(at: location)
            }
        }
        .sheet(isPresented: $showPlaceModal) {
            if let place = viewModel.placeDetail {
                VStack(spacing: 20) {
                    Text(place)
                        .font(.title)
                        .bold()
                    Button("閉じる") {
                        showPlaceModal = false
                    }
                }
                .padding()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }

    }
}

#Preview {
    HomeView()
}
