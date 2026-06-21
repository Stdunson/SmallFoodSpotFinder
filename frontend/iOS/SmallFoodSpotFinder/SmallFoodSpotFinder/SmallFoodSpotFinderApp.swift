//
//  SmallFoodSpotFinderApp.swift
//  SmallFoodSpotFinder
//
//  Created by Shavaughn Dunson on 6/20/26.
//

import SwiftUI

@main
struct SmallFoodSpotFinderApp: App {
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
        }
    }
}
