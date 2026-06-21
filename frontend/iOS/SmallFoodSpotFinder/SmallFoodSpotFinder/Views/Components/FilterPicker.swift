import SwiftUI

struct FilterPicker: View {
    @Binding var selectedDistance: Double
    @Binding var selectedCuisines: Set<String>
    @Binding var selectedPriceLevels: Set<Int>
    
    let availableDistances: [Double]
    let availableCuisines: [String]
    let availablePriceLevels: [Int]
    let onApply: () -> Void
    let onClear: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // Distance Filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Distance")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)
                
                Picker("Distance", selection: $selectedDistance) {
                    ForEach(availableDistances, id: \.self) { distance in
                        Text("\(Int(distance)) mi").tag(distance)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Divider()
            
            // Cuisine Filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Cuisine")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(availableCuisines, id: \.self) { cuisine in
                        HStack {
                            Image(systemName: selectedCuisines.contains(cuisine) ? "checkmark.square.fill" : "square")
                                .foregroundColor(selectedCuisines.contains(cuisine) ? AppColors.lightBeige : AppColors.secondaryText)
                            
                            Text(cuisine)
                                .font(.body)
                                .foregroundColor(AppColors.primaryText)
                            
                            Spacer()
                        }
                        .onTapGesture {
                            if selectedCuisines.contains(cuisine) {
                                selectedCuisines.remove(cuisine)
                            } else {
                                selectedCuisines.insert(cuisine)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Price Filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Price Level")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)
                
                HStack(spacing: 8) {
                    ForEach(availablePriceLevels, id: \.self) { level in
                        VStack {
                            Image(systemName: selectedPriceLevels.contains(level) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedPriceLevels.contains(level) ? AppColors.lightBeige : AppColors.secondaryText)
                                .font(.title3)
                            
                            Text(AppConstants.priceLabels[level] ?? "$")
                                .font(.caption)
                                .foregroundColor(AppColors.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            if selectedPriceLevels.contains(level) {
                                selectedPriceLevels.remove(level)
                            } else {
                                selectedPriceLevels.insert(level)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Buttons
            HStack(spacing: 12) {
                Button(action: onClear) {
                    Text("Clear")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(AppColors.primaryText)
                        .cornerRadius(8)
                }
                
                Button(action: onApply) {
                    Text("Apply")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.lightBeige)
                        .foregroundColor(AppColors.veryDarkBrown)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(colorScheme == .light ? AppColors.lightModeBackground : AppColors.darkModeBackground)
    }
}

#Preview {
    FilterPicker(
        selectedDistance: .constant(10),
        selectedCuisines: .constant([]),
        selectedPriceLevels: .constant([]),
        availableDistances: [1, 2, 5, 10, 20, 50],
        availableCuisines: ["Italian", "Thai", "Mexican"],
        availablePriceLevels: [1, 2, 3, 4],
        onApply: {},
        onClear: {}
    )
}
