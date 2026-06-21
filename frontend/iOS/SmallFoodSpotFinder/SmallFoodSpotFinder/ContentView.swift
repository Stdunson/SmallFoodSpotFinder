//
//  ContentView.swift
//  SmallFoodSpotFinder
//
//  Created by Shavaughn Dunson on 6/20/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Discovery Tab
            DiscoveryView()
                .tabItem {
                    Label("Discovery", systemImage: "sparkles")
                }
                .tag(0)
            
            // Search Tab
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
        }
        .onAppear {
            locationManager.requestLocationPermission()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}
