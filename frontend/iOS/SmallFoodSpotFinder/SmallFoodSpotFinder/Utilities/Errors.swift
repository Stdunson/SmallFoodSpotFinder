import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case networkError(String)
    case decodingError(String)
    case invalidData
    case unauthorized
    case rateLimitExceeded
    case notFound
    case serverError(Int, String)
    case unknown
    case locationNotAvailable
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Failed to parse response: \(message)"
        case .invalidData:
            return "Invalid data received from server"
        case .unauthorized:
            return "Unauthorized access"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        case .notFound:
            return "Resource not found"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .unknown:
            return "An unknown error occurred"
        case .locationNotAvailable:
            return "Location not available. Please enable location services."
        case .permissionDenied:
            return "Location permission denied. Please enable it in settings."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .rateLimitExceeded:
            return "Please wait a moment and try again."
        case .networkError:
            return "Check your internet connection and try again."
        case .permissionDenied:
            return "Go to Settings > SmallFoodSpotFinder > Location and enable 'While Using' location access."
        default:
            return "Please try again."
        }
    }
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidData, .invalidData),
             (.unauthorized, .unauthorized),
             (.rateLimitExceeded, .rateLimitExceeded),
             (.notFound, .notFound),
             (.unknown, .unknown),
             (.locationNotAvailable, .locationNotAvailable),
             (.permissionDenied, .permissionDenied):
            return true
        case (.networkError(let msg1), .networkError(let msg2)):
            return msg1 == msg2
        case (.decodingError(let msg1), .decodingError(let msg2)):
            return msg1 == msg2
        case (.serverError(let code1, let msg1), .serverError(let code2, let msg2)):
            return code1 == code2 && msg1 == msg2
        default:
            return false
        }
    }
}
