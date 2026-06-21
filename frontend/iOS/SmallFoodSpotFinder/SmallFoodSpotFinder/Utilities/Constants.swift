import Foundation

struct AppConstants {
    // API Configuration
    static let baseURL = "http://localhost:8000" // Update for production
    static let apiTimeout: TimeInterval = 30.0
    
    // Feature Flags
    static let enableMapKitIntegration = true
    
    // Default Values
    static let defaultSearchDistanceMiles: Double = 10.0
    static let defaultDistanceOptions: [Double] = [1, 2, 5, 10, 20, 50]
    static let defaultPriceLevels: [Int] = [1, 2, 3, 4]
    
    // Cuisine Categories
    static let defaultCuisines = [
        "Italian",
        "Thai",
        "Mexican",
        "Asian",
        "Chinese",
        "Japanese",
        "Indian",
        "Mediterranean",
        "American",
        "French",
        "Korean",
        "Vietnamese",
        "Fusion",
        "Other"
    ]
    
    // Price Labels
    static let priceLabels: [Int: String] = [
        1: "$",
        2: "$$",
        3: "$$$",
        4: "$$$$"
    ]
    
    // Rate Limiting
    static let discoveryRateLimit = 10 // requests per minute
    static let searchRateLimit = 20 // requests per minute
    static let detailRateLimit = 30 // requests per minute
    
    // Location Permissions
    static let locationPermissionDescription = "We need your location to show nearby restaurants"
    
    // Debounce Timing
    static let searchDebounceInterval: TimeInterval = 0.5
}

enum NavigationDestination: Hashable {
    case discovery
    case search
    case detail(restaurantId: Int)
}
