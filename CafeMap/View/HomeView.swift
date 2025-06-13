//
//  HomeView.swift
//  CafeMap
//
//  Created by 정건호 on 4/4/25.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var currentLocation: CLLocationCoordinate2D?
    @State private var searchedLocation: CLLocationCoordinate2D?
    @State private var isMapDragged: Bool = false
    @State private var reloadButtonClicked = false
    @State private var moveToUserLocation = false
    @State private var searchByText = false
    @State private var showPlaceModal = false
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let region = viewModel.currentRegion {
                //　検索バー
                VStack {
                    ZStack {
                        HStack {
                            TextField(isSearchFocused ? String() : "🔎　ここで駅を検索", text: $searchText)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                                .padding(.horizontal)
                                .focused($isSearchFocused)
                                .submitLabel(.search)
                                .onChange(of: isSearchFocused) { _ in
                                    reloadButtonClicked = false
                                }
                                .onSubmit {
                                    Task {
                                        if !searchText.isEmpty {
                                            let refinedText = searchText.replacingOccurrences(of: "駅", with: String()).trimmingCharacters(in: .whitespaces)
                                            isSearchFocused = false
                                            let searchedLocation = await viewModel.searchPlaces(keyword: refinedText)
                                            self.searchedLocation = searchedLocation
                                            searchText = String()
                                        }
                                    }
                                }
                        }
                        HStack {
                            if !searchText.isEmpty && isSearchFocused {
                                Spacer()
                                Image(systemName: "xmark.circle")
                                    .font(.system(size: 24))
                                    .padding(.trailing, 24)
                                    .onTapGesture {
                                        searchText = String()
                                    }
                            }
                        }
                        .zIndex(1)
                    }
                    Spacer()
                }
                .zIndex(1)
                //　マップ
                CustomMapView(
                    region: region,
                    places: viewModel.places,
                    onAnnotationTap: { place in
                        Task {
                            await viewModel.fetchDetailPlace(id: place.id)
                            await viewModel.fetchPlaceReview(id: place.id)
                            showPlaceModal = true
                        }
                    },
                    currentLocation: $currentLocation,
                    searchedLocation: $searchedLocation, isMapDragged: $isMapDragged,
                    reloadButtonClicked: $reloadButtonClicked,
                    moveToUserLocation: $moveToUserLocation
                )
                .ignoresSafeArea(edges: .top)
                .onReceive(router.$location.compactMap { $0 }) { location in
                    isMapDragged = true
                    Task {
                        await viewModel.fetchDetailPlace(id: router.selectedPlaceID ?? String(), from: .bookmark)
                        reloadButtonClicked = true
                        searchedLocation = location
                    }
                }
                
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
        .ignoresSafeArea(.keyboard)
        .onReceive(locationManager.$currentLocation.compactMap { $0 }) { location in
            Task(priority: .userInitiated) {
                await viewModel.fetchNearbyPlaces(at: location)
            }
        }
        .sheet(isPresented: $showPlaceModal) {
            if let place = viewModel.placeDetail {
                PlaceDetailModalView(viewModel: viewModel, place: place, showModal: $showPlaceModal)
                    .presentationDetents([.medium, .fraction(0.999)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    HomeView()
}
