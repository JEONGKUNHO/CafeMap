//
//  CafeMapApp.swift
//  CafeMap
//
//  Created by 정건호 on 4/2/25.
//

import SwiftUI
import GooglePlaces

@main
struct CafeMapApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_API_KEY") as? String {
            GMSPlacesClient.provideAPIKey(apiKey)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
