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
            Map(coordinateRegion: .constant(viewModel.currentRegion ?? MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 35.6812715, longitude: 139.6846647), // デフォルトは東京駅
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )),
                showsUserLocation: true,
                annotationItems: viewModel.places)
            { place in
                MapAnnotation(coordinate: place.coordinate) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .imageScale(.large)
                    }
                    .onTapGesture {
                        Task {
                            await viewModel.fetchDetailPlace(id: place.id)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .onReceive(locationManager.$currentLocation) { location in
            if let location = location {
                Task {
                    await viewModel.fetchNearbyPlaces(at: location)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
