//
//  DiscoveryView.swift
//  SmallFoodSpotFinder
//
//  Created by Shavaughn Dunson on 6/20/26.
//

import SwiftUI
import CoreLocation

struct DiscoveryView: View {
    @StateObject private var viewModel = DiscoveryViewModel()
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                (colorScheme == .light ? AppColors.lightModeBackground : AppColors.darkModeBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingSpinner()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("Error")
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            Task {
                                await viewModel.fetchDiscoveryRecommendations()
                            }
                        }) {
                            Text("Try Again")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(AppColors.lightBeige)
                                .foregroundColor(AppColors.veryDarkBrown)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Header
                            Text("Local Eateries Near You")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                                .padding(.horizontal)
                            
                            // Recommendations
                            if viewModel.recommendations.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppColors.secondaryText)
                                    
                                    Text("No Recommendations Found")
                                        .font(.headline)
                                        .foregroundColor(AppColors.primaryText)
                                    
                                    Text("Try checking back later or adjust your search")
                                        .font(.body)
                                        .foregroundColor(AppColors.secondaryText)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.recommendations, id: \.id) { recommendation in
                                        RestaurantCard(
                                            restaurant: recommendation,
                                            onDetailsPressed: {
                                                viewModel.selectRestaurant(recommendation.restaurantId)
                                            },
                                            onDirectionsPressed: {
                                                viewModel.selectRestaurant(recommendation.restaurantId)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Search Button
                            NavigationLink(destination: SearchView()) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text("Search")
                                    Spacer()
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppColors.lightBeige)
                                .foregroundColor(AppColors.veryDarkBrown)
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
            .navigationTitle("Discovery")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.locationManager = locationManager
                if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                    await viewModel.fetchDiscoveryRecommendations()
                }
            }
            .navigationDestination(item: $viewModel.selectedRestaurantId) { restaurantId in
                DetailView(restaurantId: restaurantId)
            }
        }
    }
}

#Preview {
    DiscoveryView()
        .environmentObject(LocationManager())
}

