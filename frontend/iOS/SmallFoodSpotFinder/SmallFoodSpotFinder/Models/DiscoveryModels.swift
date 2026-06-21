import Foundation

// MARK: - Discovery Recommendation

struct DiscoveryRecommendation: Codable, Identifiable, Hashable {
    let id: Int
    let spotNumber: Int
    let name: String
    let typeOfFood: String
    let priceCategory: String
    let distanceMiles: Double
    let isFeatured: Bool
    let restaurantId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case spotNumber = "spot_number"
        case name
        case typeOfFood = "type_of_food"
        case priceCategory = "price_category"
        case distanceMiles = "distance_miles"
        case isFeatured = "is_featured"
        case restaurantId = "restaurant_id"
    }
}

// MARK: - Discovery Response

struct DiscoveryResponse: Codable {
    let timestamp: String
    let userLocation: Location
    let recommendations: [DiscoveryRecommendation]
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case userLocation = "user_location"
        case recommendations
    }
}

