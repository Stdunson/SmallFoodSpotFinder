import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: URL
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(baseURL: String = AppConstants.baseURL) {
        self.baseURL = URL(string: baseURL) ?? URL(fileURLWithPath: "")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConstants.apiTimeout
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }
    
    // MARK: - Discovery Endpoint
    
    func fetchDiscoveryRecommendations(latitude: Double, longitude: Double) async throws -> DiscoveryResponse {
        let endpoint = baseURL.appendingPathComponent("discovery")
        
        let requestBody: [String: Double] = [
            "latitude": latitude,
            "longitude": longitude
        ]
        
        let response: DiscoveryResponse = try await makeRequest(
            url: endpoint,
            method: "POST",
            body: requestBody
        )
        
        return response
    }
    
    // MARK: - Search Endpoint
    
    private struct SearchRequestBody: Encodable {
        let latitude: Double
        let longitude: Double
        let categories: [String]?
        let price_categories: [Int]?
        let distance_miles: Double?
        let search_query: String?
        
        enum CodingKeys: String, CodingKey {
            case latitude
            case longitude
            case categories
            case price_categories = "price_categories"
            case distance_miles = "distance_miles"
            case search_query = "search_query"
        }
    }
    
    func searchRestaurants(
        latitude: Double,
        longitude: Double,
        categories: [String]? = nil,
        priceCategories: [Int]? = nil,
        distanceMiles: Double? = nil,
        searchQuery: String? = nil
    ) async throws -> SearchResponse {
        let endpoint = baseURL.appendingPathComponent("search")
        
        let requestBody = SearchRequestBody(
            latitude: latitude,
            longitude: longitude,
            categories: categories,
            price_categories: priceCategories,
            distance_miles: distanceMiles,
            search_query: (searchQuery?.isEmpty == false ? searchQuery : nil)
        )
        
        let response: SearchResponse = try await makeRequest(
            url: endpoint,
            method: "POST",
            body: requestBody
        )
        
        return response
    }
    
    // MARK: - Restaurant Details Endpoint
    
    func fetchRestaurantDetails(restaurantId: Int) async throws -> RestaurantDetails {
        let endpoint = baseURL.appendingPathComponent("restaurant").appendingPathComponent("details")
        
        let requestBody: [String: Int] = [
            "restaurant_id": restaurantId
        ]
        
        let response: RestaurantDetails = try await makeRequest(
            url: endpoint,
            method: "POST",
            body: requestBody
        )
        
        return response
    }
    
    // MARK: - Generic Request Method
    
    private func makeRequest<T: Decodable>(
        url: URL,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            if let dictBody = body as? [String: Any] {
                request.httpBody = try JSONSerialization.data(withJSONObject: dictBody, options: [])
            } else {
                request.httpBody = try encoder.encode(body)
            }
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decodedResponse = try decoder.decode(T.self, from: data)
                return decodedResponse
            } catch {
                throw APIError.decodingError(error.localizedDescription)
            }
        case 400:
            throw APIError.invalidData
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 429:
            throw APIError.rateLimitExceeded
        case 500...599:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        default:
            throw APIError.unknown
        }
    }
}
