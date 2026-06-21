import Foundation

// MARK: - Base Restaurant Model

struct Restaurant: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let typeOfFood: String
    let priceLevel: Int
    let priceLabel: String
    let distanceMiles: Double
    let rating: Double?
    let isFeatured: Bool
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
        case typeOfFood = "type_of_food"
        case priceLevel = "price_level"
        case priceLabel = "price_label"
        case distanceMiles = "distance_miles"
        case rating
        case isFeatured = "is_featured"
        case phone
        case website
        case hours
        case categories
    }
}

// MARK: - Hour Entry

struct HourEntry: Codable, Identifiable, Hashable {
    let id = UUID()
    let dayOfWeek: String
    let openingTime: String
    let closingTime: String
    let isOpen: Bool
    let isOvernight: Bool
    
    enum CodingKeys: String, CodingKey {
        case dayOfWeek = "day_of_week"
        case openingTime = "opening_time"
        case closingTime = "closing_time"
        case isOpen = "is_open"
        case isOvernight = "is_overnight"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(dayOfWeek)
        hasher.combine(openingTime)
        hasher.combine(closingTime)
    }
    
    static func == (lhs: HourEntry, rhs: HourEntry) -> Bool {
        lhs.dayOfWeek == rhs.dayOfWeek && lhs.openingTime == rhs.openingTime && lhs.closingTime == rhs.closingTime
    }
}

// MARK: - Location

struct Location: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}
