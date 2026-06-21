import Foundation
import Combine

@MainActor
class DiscoveryViewModel: ObservableObject {
    @Published var recommendations: [DiscoveryRecommendation] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedRestaurantId: Int?
    
    private let apiClient: APIClient
    weak var locationManager: LocationManager?
    
    init(apiClient: APIClient = .shared, locationManager: LocationManager? = nil) {
        self.apiClient = apiClient
        self.locationManager = locationManager
    }
    
    func fetchDiscoveryRecommendations() async {
        guard let locationManager = locationManager else {
            errorMessage = "Location manager not available"
            return
        }
        
        if locationManager.userLatitude == 0 && locationManager.userLongitude == 0 {
            errorMessage = "Location not yet determined"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiClient.fetchDiscoveryRecommendations(
                latitude: locationManager.userLatitude,
                longitude: locationManager.userLongitude
            )
            self.recommendations = response.recommendations
        } catch {
            if let apiError = error as? APIError {
                self.errorMessage = apiError.errorDescription
            } else {
                self.errorMessage = "Failed to fetch recommendations: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    func selectRestaurant(_ id: Int) {
        selectedRestaurantId = id
    }
    
    func clearSelection() {
        selectedRestaurantId = nil
    }
}
