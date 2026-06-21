import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    // Search State
    @Published var searchQuery: String = ""
    @Published var selectedDistanceMile: Double = AppConstants.defaultSearchDistanceMiles
    @Published var selectedCuisines: Set<String> = []
    @Published var selectedPriceLevels: Set<Int> = []
    
    // Display State
    @Published var searchResults: [SearchResult] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedRestaurantId: Int?
    @Published var showFilters: Bool = false
    
    // Filter Options
    @Published var availableCuisines: [String] = AppConstants.defaultCuisines
    @Published var availablePriceLevels: [Int] = AppConstants.defaultPriceLevels
    @Published var availableDistances: [Double] = AppConstants.defaultDistanceOptions
    
    private let apiClient: APIClient
    private weak var locationManager: LocationManager?
    private var searchDebounceTimer: Timer?
    
    init(apiClient: APIClient = .shared, locationManager: LocationManager? = nil) {
        self.apiClient = apiClient
        self.locationManager = locationManager
    }
    
    func performSearch() async {
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
            let response = try await apiClient.searchRestaurants(
                latitude: locationManager.userLatitude,
                longitude: locationManager.userLongitude,
                categories: selectedCuisines.isEmpty ? nil : Array(selectedCuisines),
                priceCategories: selectedPriceLevels.isEmpty ? nil : Array(selectedPriceLevels),
                distanceMiles: selectedDistanceMile,
                searchQuery: searchQuery.isEmpty ? nil : searchQuery
            )
            self.searchResults = response.results
        } catch {
            if let apiError = error as? APIError {
                self.errorMessage = apiError.errorDescription
            } else {
                self.errorMessage = "Failed to search restaurants: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    func performSearchWithDebounce() {
        searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: AppConstants.searchDebounceInterval, repeats: false) { [weak self] _ in
            Task {
                await self?.performSearch()
            }
        }
    }
    
    func clearFilters() {
        searchQuery = ""
        selectedDistanceMile = AppConstants.defaultSearchDistanceMiles
        selectedCuisines.removeAll()
        selectedPriceLevels.removeAll()
        searchResults = []
        errorMessage = nil
    }
    
    func toggleCuisine(_ cuisine: String) {
        if selectedCuisines.contains(cuisine) {
            selectedCuisines.remove(cuisine)
        } else {
            selectedCuisines.insert(cuisine)
        }
    }
    
    func togglePriceLevel(_ level: Int) {
        if selectedPriceLevels.contains(level) {
            selectedPriceLevels.remove(level)
        } else {
            selectedPriceLevels.insert(level)
        }
    }
    
    func setLocationManager(_ manager: LocationManager) {
        self.locationManager = manager
    }
    
    func setDistance(_ distance: Double) {
        selectedDistanceMile = distance
    }
    
    func selectRestaurant(_ id: Int) {
        selectedRestaurantId = id
    }
    
    func clearSelection() {
        selectedRestaurantId = nil
    }
}
