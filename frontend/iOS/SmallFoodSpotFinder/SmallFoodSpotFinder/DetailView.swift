//
//  DetailView.swift
//  SmallFoodSpotFinder
//
//  Created by Shavaughn Dunson on 6/20/26.
//

import SwiftUI

struct DetailView: View {
    let restaurantId: Int
    @StateObject private var viewModel: DetailViewModel
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    init(restaurantId: Int) {
        self.restaurantId = restaurantId
        _viewModel = StateObject(wrappedValue: DetailViewModel(restaurantId: restaurantId))
    }
    
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
                        
                        Text("Error Loading Details")
                            .font(.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            Task {
                                await viewModel.fetchRestaurantDetails()
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
                } else if let details = viewModel.restaurantDetails {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Featured Image
                            ZStack {
                                Rectangle()
                                    .fill(AppColors.mediumBeige)
                                
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppColors.veryDarkBrown.opacity(0.3))
                            }
                            .frame(height: 200)
                            .cornerRadius(12)
                            
                            // Restaurant Info
                            VStack(alignment: .leading, spacing: 12) {
                                Text(details.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.primaryText)
                                
                                HStack(spacing: 12) {
                                    if let rating = details.rating {
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                            
                                            Text(String(format: "%.1f", rating))
                                                .font(.subheadline)
                                                .foregroundColor(AppColors.secondaryText)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text(AppConstants.priceLabels[details.priceCategory] ?? "$")
                                        .font(.headline)
                                        .foregroundColor(AppColors.veryDarkBrown)
                                }
                            }
                            .padding()
                            .background(colorScheme == .light ? AppColors.lightModeCardBackground : AppColors.darkModeCardBackground)
                            .cornerRadius(12)
                            
                            // Address
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Address", systemImage: "mappin.circle.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.primaryText)
                                
                                Text(details.address.fullAddress)
                                    .font(.body)
                                    .foregroundColor(AppColors.secondaryText)
                                    .lineLimit(nil)
                                
                                if let distance = details.distanceMiles {
                                    Text("\(String(format: "%.1f", distance)) miles away")
                                        .font(.caption)
                                        .foregroundColor(AppColors.secondaryText)
                                }
                            }
                            .padding()
                            .background(colorScheme == .light ? AppColors.lightModeCardBackground : AppColors.darkModeCardBackground)
                            .cornerRadius(12)
                            
                            // Categories
                            if !details.categories.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Cuisine", systemImage: "fork.knife")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.primaryText)
                                    
                                    HStack(spacing: 8) {
                                        ForEach(details.categories, id: \.self) { category in
                                            Text(category)
                                                .font(.caption)
                                                .padding(.vertical, 4)
                                                .padding(.horizontal, 8)
                                                .background(AppColors.lightBeige.opacity(0.3))
                                                .cornerRadius(4)
                                                .foregroundColor(AppColors.veryDarkBrown)
                                        }
                                    }
                                }
                                .padding()
                                .background(colorScheme == .light ? AppColors.lightModeCardBackground : AppColors.darkModeCardBackground)
                                .cornerRadius(12)
                            }
                            
                            // Contact Info
                            VStack(alignment: .leading, spacing: 12) {
                                if let phone = details.phone, !phone.isEmpty {
                                    Button(action: viewModel.callRestaurant) {
                                        HStack {
                                            Image(systemName: "phone.fill")
                                                .foregroundColor(AppColors.veryDarkBrown)
                                            
                                            Text(phone)
                                                .foregroundColor(AppColors.veryDarkBrown)
                                            
                                            Spacer()
                                        }
                                        .font(.body)
                                        .padding()
                                        .background(AppColors.lightBeige)
                                        .cornerRadius(8)
                                    }
                                }
                                
                                if let website = details.website, !website.isEmpty {
                                    Button(action: viewModel.openWebsite) {
                                        HStack {
                                            Image(systemName: "globe")
                                                .foregroundColor(AppColors.veryDarkBrown)
                                            
                                            Text(website)
                                                .foregroundColor(AppColors.veryDarkBrown)
                                                .lineLimit(1)
                                            
                                            Spacer()
                                        }
                                        .font(.body)
                                        .padding()
                                        .background(AppColors.lightBeige)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding()
                            .background(colorScheme == .light ? AppColors.lightModeCardBackground : AppColors.darkModeCardBackground)
                            .cornerRadius(12)
                            
                            // Hours
                            if !details.hours.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Label("Hours", systemImage: "clock.fill")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.primaryText)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(details.hours, id: \.id) { hour in
                                            HStack {
                                                Text(hour.dayOfWeek)
                                                    .font(.caption)
                                                    .foregroundColor(AppColors.secondaryText)
                                                
                                                Spacer()
                                                
                                                if hour.isOpen {
                                                    Text("\(hour.openingTime) - \(hour.closingTime)")
                                                        .font(.caption)
                                                        .foregroundColor(AppColors.primaryText)
                                                } else {
                                                    Text("Closed")
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(colorScheme == .light ? AppColors.lightModeCardBackground : AppColors.darkModeCardBackground)
                                .cornerRadius(12)
                            }
                            
                            Spacer(minLength: 16)
                        }
                        .padding()
                    }
                    
                    // Bottom Action Buttons
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Button(action: viewModel.openInMaps) {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("Get Directions")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppColors.lightBeige)
                                .foregroundColor(AppColors.veryDarkBrown)
                                .cornerRadius(8)
                            }
                            
                            if details.phone != nil {
                                Button(action: viewModel.callRestaurant) {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                        Text("Call")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(AppColors.lightBeige)
                                    .foregroundColor(AppColors.veryDarkBrown)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(colorScheme == .light ? AppColors.lightModeBackground : AppColors.darkModeBackground)
                } else {
                    Text("No Details Available")
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            .navigationTitle(viewModel.restaurantName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .task {
                viewModel.locationManager = locationManager
                await viewModel.fetchRestaurantDetails()
            }
        }
    }
}

#Preview {
    DetailView(restaurantId: 1)
        .environmentObject(LocationManager())
}
