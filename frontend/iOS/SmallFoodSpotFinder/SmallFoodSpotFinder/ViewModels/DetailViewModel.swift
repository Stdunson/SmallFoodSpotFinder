import UIKit
import Foundation
import Combine

@MainActor
class DetailViewModel: ObservableObject {
    @Published var restaurantDetails: RestaurantDetails?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var restaurantName: String = ""
    
    private let apiClient: APIClient
    weak var locationManager: LocationManager?
    private let restaurantId: Int
    
    init(restaurantId: Int, apiClient: APIClient = .shared, locationManager: LocationManager? = nil) {
        self.restaurantId = restaurantId
        self.apiClient = apiClient
        self.locationManager = locationManager
    }
    
    func fetchRestaurantDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let details = try await apiClient.fetchRestaurantDetails(restaurantId: restaurantId)
            self.restaurantDetails = details
            self.restaurantName = details.name
        } catch {
            if let apiError = error as? APIError {
                self.errorMessage = apiError.errorDescription
            } else {
                self.errorMessage = "Failed to fetch restaurant details: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    func openInMaps() {
        guard let details = restaurantDetails else { return }
        
        let latitude = details.address.latitude
        let longitude = details.address.longitude
        
        let scheme = "maps://maps.apple.com/?saddr=&daddr=\(latitude),\(longitude)&dirflg=d"
        
        if let url = URL(string: scheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    func callRestaurant() {
        guard let phone = restaurantDetails?.phone else { return }
        
        let cleanedPhone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if let url = URL(string: "tel://\(cleanedPhone)") {
            UIApplication.shared.open(url)
        }
    }
    
    func openWebsite() {
        guard let website = restaurantDetails?.website, !website.isEmpty else { return }
        
        var urlString = website
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://\(urlString)"
        }
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func getFormattedHours() -> String {
        guard let hours = restaurantDetails?.hours, !hours.isEmpty else {
            return "Hours not available"
        }
        
        let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let today = Calendar.current.component(.weekday, from: Date()) - 1 // Adjust for array index
        
        var hoursString = ""
        for (index, hour) in hours.prefix(5).enumerated() {
            if index > 0 {
                hoursString += "\n"
            }
            let dayLabel = index == today ? "Today: " : "\(hour.dayOfWeek): "
            hoursString += "\(dayLabel)\(hour.openingTime) - \(hour.closingTime)"
        }
        
        if hours.count > 5 {
            hoursString += "\n..."
        }
        
        return hoursString
    }
}
