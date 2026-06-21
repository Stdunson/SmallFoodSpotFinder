//
//  SearchView.swift
//  SmallFoodSpotFinder
//
//  Created by Shavaughn Dunson on 6/20/26.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.colorScheme) var colorScheme
    @State private var region = MKCoordinateRegion()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                (colorScheme == .light ? AppColors.lightModeBackground : AppColors.darkModeBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with Map Toggle
                    HStack {
                        NavigationLink(destination: DiscoveryView()) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.veryDarkBrown)
                        }
                        
                        Spacer()
                        
                        Text("Map")
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        Spacer()
                        
                        Button(action: { viewModel.showFilters.toggle() }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.veryDarkBrown)
                        }
                    }
                    .padding()
                    .background(AppColors.lightBeige)
                    
                    // Map
                    if locationManager.userLatitude != 0 && locationManager.userLongitude != 0 {
                        MapViewContainer(
                            region: $region,
                            userLatitude: locationManager.userLatitude,
                            userLongitude: locationManager.userLongitude,
                            results: viewModel.searchResults,
                            selectedResultId: $viewModel.selectedRestaurantId
                        )
                        .frame(height: 200)
                    }
                    
                    // Search Bar
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.secondaryText)
                            
                            TextField("Search restaurants", text: $viewModel.searchQuery)
                                .font(.body)
                                .onChange(of: viewModel.searchQuery) { _ in
                                    viewModel.performSearchWithDebounce()
                                }
                            
                            if !viewModel.searchQuery.isEmpty {
                                Button(action: { viewModel.searchQuery = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppColors.secondaryText)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        
                        // Filter Summary
                        HStack(spacing: 8) {
                            if !viewModel.selectedCuisines.isEmpty {
                                Text("Cuisines: \(viewModel.selectedCuisines.joined(separator: ", "))")
                                    .font(.caption2)
                                    .padding(6)
                                    .background(AppColors.lightBeige.opacity(0.5))
                                    .cornerRadius(4)
                            }
                            
                            if !viewModel.selectedPriceLevels.isEmpty {
                                Text("Price: \(viewModel.selectedPriceLevels.sorted().map { AppConstants.priceLabels[$0] ?? "" }.joined(separator: ""))")
                                    .font(.caption2)
                                    .padding(6)
                                    .background(AppColors.lightBeige.opacity(0.5))
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding()
                    
                    // Results List
                    if viewModel.isLoading {
                        LoadingSpinner()
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.orange)
                            
                            Text(errorMessage)
                                .font(.body)
                                .foregroundColor(AppColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else if viewModel.searchResults.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.secondaryText)
                            
                            Text("No Results Found")
                                .font(.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("Try adjusting your search or filters")
                                .font(.body)
                                .foregroundColor(AppColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(viewModel.searchResults, id: \.id) { result in
                                    RestaurantRow(restaurant: result, onTapped: {
                                        viewModel.selectRestaurant(result.id)
                                    })
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showFilters) {
                FilterPicker(
                    selectedDistance: $viewModel.selectedDistanceMile,
                    selectedCuisines: $viewModel.selectedCuisines,
                    selectedPriceLevels: $viewModel.selectedPriceLevels,
                    availableDistances: viewModel.availableDistances,
                    availableCuisines: viewModel.availableCuisines,
                    availablePriceLevels: viewModel.availablePriceLevels,
                    onApply: {
                        Task {
                            await viewModel.performSearch()
                        }
                        viewModel.showFilters = false
                    },
                    onClear: {
                        viewModel.clearFilters()
                        viewModel.showFilters = false
                    }
                )
            }
            .task {
                viewModel.setLocationManager(locationManager)
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: locationManager.userLatitude,
                        longitude: locationManager.userLongitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
            .navigationDestination(item: $viewModel.selectedRestaurantId) { restaurantId in
                DetailView(restaurantId: restaurantId)
            }
        }
    }
}

struct MapViewContainer: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let userLatitude: Double
    let userLongitude: Double
    let results: [SearchResult]
    @Binding var selectedResultId: Int?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)
        userAnnotation.title = "Your Location"
        mapView.addAnnotation(userAnnotation)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Remove old restaurant annotations
        let restaurantAnnotations = uiView.annotations.filter { !($0 is MKUserLocation) && $0.title != "Your Location" }
        uiView.removeAnnotations(restaurantAnnotations)
        
        // Add restaurant annotations
        for result in results {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
            annotation.title = result.name
            annotation.subtitle = result.category
            uiView.addAnnotation(annotation)
        }
        
        // Update region
        var newRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        if !results.isEmpty {
            var minLat = results[0].latitude
            var maxLat = results[0].latitude
            var minLon = results[0].longitude
            var maxLon = results[0].longitude
            
            for result in results {
                minLat = min(minLat, result.latitude)
                maxLat = max(maxLat, result.latitude)
                minLon = min(minLon, result.longitude)
                maxLon = max(maxLon, result.longitude)
            }
            
            let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
            let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLon - minLon) * 1.3)
            newRegion = MKCoordinateRegion(center: center, span: span)
        }
        
        uiView.setRegion(newRegion, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewContainer
        
        init(_ parent: MapViewContainer) {
            self.parent = parent
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(LocationManager())
}
