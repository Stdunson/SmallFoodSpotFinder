import SwiftUI
import Foundation

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let r = Double((hexNumber & 0xFF000000) >> 24) / 255
            let g = Double((hexNumber & 0x00FF0000) >> 16) / 255
            let b = Double((hexNumber & 0x0000FF00) >> 8) / 255
            let a = Double(hexNumber & 0x000000FF) / 255
            
            self.init(red: r, green: g, blue: b, opacity: a)
        } else {
            self.init(red: 0, green: 0, blue: 0, opacity: 1)
        }
    }
}

extension Double {
    func formattedAsPrice() -> String {
        return AppConstants.priceLabels[Int(self)] ?? "$"
    }
    
    func formattedAsDistance() -> String {
        if self < 1.0 {
            return String(format: "%.1f mi", self)
        } else {
            return String(format: "%.1f mi", self)
        }
    }
    
    func formattedAsRating() -> String {
        return String(format: "%.1f", self)
    }
}

extension String {
    func isValidURL() -> Bool {
        let urlPattern = "^(https?://)?" + "((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|" +
        "((\\d{1,3}\\.){3}\\d{1,3}))" + "(\\:\\d+)?(/[-a-z\\d%_.~+]*)*" +
        "(\\?[;&a-z\\d%_.~+=-]*)?" + "(\\#[-a-z\\d_]*)?$"
        return NSPredicate(format: "SELF MATCHES %@", urlPattern).evaluate(with: self)
    }
}

extension View {
    func applyCardStyle(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(Color(UIColor.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
