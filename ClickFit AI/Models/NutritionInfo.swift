import Foundation

struct NutritionInfo: Codable {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    
    var formattedProtein: String {
        String(format: "%.1f", protein)
    }
    
    var formattedCarbs: String {
        String(format: "%.1f", carbs)
    }
    
    var formattedFat: String {
        String(format: "%.1f", fat)
    }
}