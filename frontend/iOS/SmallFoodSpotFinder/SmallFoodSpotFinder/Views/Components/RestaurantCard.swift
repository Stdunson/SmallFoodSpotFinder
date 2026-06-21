import SwiftUI

struct RestaurantCard: View {
    let restaurant: DiscoveryRecommendation
    let onDetailsPressed: () -> Void
    let onDirectionsPressed: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image Placeholder
            ZStack {
                Rectangle()
                    .fill(AppColors.mediumBeige)
                    .frame(height: 150)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.veryDarkBrown)
            }
            .cornerRadius(8)
            
            // Info Section
            VStack(alignment: .leading, spacing: 4) {
                Text("Spot #\(restaurant.spotNumber)")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    Label(restaurant.typeOfFood, systemImage: "fork.knife")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Text(AppConstants.priceLabels[Int(restaurant.priceCategory.first?.asciiValue ?? 36)] ?? restaurant.priceCategory)
                        .font(.caption)
                        .foregroundColor(AppColors.veryDarkBrown)
                }
                
                Text("\(String(format: "%.1f", restaurant.distanceMiles)) mi")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(.horizontal, 8)
            
            // Buttons
            HStack(spacing: 12) {
                Button(action: onDetailsPressed) {
                    Text("Details")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppColors.lightBeige)
                        .foregroundColor(AppColors.veryDarkBrown)
                        .cornerRadius(6)
                }
                
                Button(action: onDirectionsPressed) {
                    Text("Directions")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppColors.lightBeige)
                        .foregroundColor(AppColors.veryDarkBrown)
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(colorScheme == .light ? AppColors.lightModeCardBackground : AppColors.darkModeCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let sample = DiscoveryRecommendation(
        id: 1,
        spotNumber: 1,
        name: "Antonio's Italian Kitchen",
        typeOfFood: "Italian",
        priceCategory: "$$",
        distanceMiles: 0.5,
        isFeatured: true,
        restaurantId: 1
    )
    
    RestaurantCard(
        restaurant: sample,
        onDetailsPressed: {},
        onDirectionsPressed: {}
    )
    .padding()
}
