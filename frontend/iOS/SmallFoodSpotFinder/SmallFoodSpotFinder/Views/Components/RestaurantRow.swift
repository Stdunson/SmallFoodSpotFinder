import SwiftUI

struct RestaurantRow: View {
    let restaurant: SearchResult
    let onTapped: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTapped) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(restaurant.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primaryText)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(restaurant.priceLabel)
                            .font(.caption)
                            .foregroundColor(AppColors.veryDarkBrown)
                    }
                    
                    HStack(spacing: 8) {
                        Text(restaurant.category)
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("•")
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("\(String(format: "%.1f", restaurant.distanceMiles)) mi")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryText)
                        
                        if restaurant.isFeatured {
                            Spacer()
                            Text("⭐ Featured")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.primaryButton)
                        }
                    }
                    
                    if let rating = restaurant.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text(String(format: "%.1f", rating))
                                .font(.caption2)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(colorScheme == .light ? AppColors.lightModeCardBackground : AppColors.darkModeCardBackground)
            .cornerRadius(8)
        }
    }
}

#Preview {
    let sample = SearchResult(
        id: 1,
        name: "Antonio's Italian Kitchen",
        address: "123 Main St",
        latitude: 40.7128,
        longitude: -74.0060,
        category: "Italian",
        priceLevel: 2,
        priceLabel: "$$",
        distanceMiles: 0.5,
        rating: 4.5,
        isFeatured: true,
        type: "featured_spot",
        phone: "555-1234",
        website: "antonios.com",
        hours: nil,
        categories: ["Italian", "Pizza"]
    )
    
    RestaurantRow(restaurant: sample, onTapped: {})
        .padding()
}
