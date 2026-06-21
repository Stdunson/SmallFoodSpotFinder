import Foundation

// MARK: - Search Result

struct SearchResult: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: String
    let priceLevel: Int
    let priceLabel: String
    let distanceMiles: Double
    let rating: Double?
    let isFeatured: Bool
    let type: String
    let phone: String?
    let website: String?
    let hours: [HourEntry]?
    let categories: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "restaurant_id"
        case name
        case address
        case latitude
        case longitude
        case category
        case priceLevel = "price_level"
        case priceLabel = "price_label"
        case distanceMiles = "distance_miles"
        case rating
        case isFeatured = "is_featured"
        case type
        case phone
        case website
        case hours
        case categories
    }
}

// MARK: - Search Parameters

struct SearchParams: Codable, Hashable {
    let distanceMiles: Double
    let categories: [String]?
    let priceCategories: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case distanceMiles = "distance_miles"
        case categories
        case priceCategories = "price_categories"
    }
}

// MARK: - Search Response

struct SearchResponse: Codable {
    let timestamp: String
    let userLocation: Location
    let searchParams: SearchParams
    let results: [SearchResult]
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case userLocation = "user_location"
        case searchParams = "search_params"
        case results
        case totalCount = "total_count"
    }
}
