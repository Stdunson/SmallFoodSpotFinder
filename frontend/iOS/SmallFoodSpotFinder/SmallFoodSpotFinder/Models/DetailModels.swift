import Foundation

// MARK: - Address Info

struct AddressInfo: Codable, Hashable {
    let fullAddress: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case fullAddress = "full_address"
        case latitude
        case longitude
    }
}

// MARK: - Restaurant Details

struct RestaurantDetails: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let address: AddressInfo
    let priceCategory: Int
    let categories: [String]
    let hours: [HourEntry]
    let website: String?
    let phone: String?
    let rating: Double?
    let distanceMiles: Double?
    let isFeatured: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "restaurant_id"
        case name
        case address
        case priceCategory = "price_category"
        case categories
        case hours
        case website
        case phone
        case rating
        case distanceMiles = "distance_miles"
        case isFeatured = "is_featured"
    }
}
