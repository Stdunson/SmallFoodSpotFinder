import SwiftUI

struct AppColors {
    // Primary Colors (Brand)
    static let lightBeige = Color(red: 1.0, green: 0.827, blue: 0.675) // #FFD3AC
    static let mediumBeige = Color(red: 0.8, green: 0.745, blue: 0.694) // #CCBEB1
    static let darkBrown = Color(red: 0.4, green: 0.298, blue: 0.212) // #664C36
    static let veryDarkBrown = Color(red: 0.2, green: 0.11, blue: 0.031) // #331C08
    
    // Semantic Colors
    static let primaryButton = Color(red: 1.0, green: 0.827, blue: 0.675) // #FFD3AC
    static let primaryText = Color(red: 0.2, green: 0.11, blue: 0.031) // #331C08
    static let secondaryText = Color(red: 0.4, green: 0.298, blue: 0.212) // #664C36
    
    // Light Mode
    static let lightModeBackground = Color.white
    static let lightModeCardBackground = Color(red: 0.8, green: 0.745, blue: 0.694) // #CCBEB1
    
    // Dark Mode
    static let darkModeBackground = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let darkModeCardBackground = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    // Status Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue
}
