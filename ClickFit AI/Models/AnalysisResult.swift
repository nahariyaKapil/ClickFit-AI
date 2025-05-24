import Foundation

struct AnalysisResult: Codable {
    let mealName: String
    let totalCalories: Int
    let confidence: Double
    let ingredients: [IngredientData]
    let totals: NutritionData
    
    enum CodingKeys: String, CodingKey {
        case mealName = "meal_name"
        case totalCalories = "total_calories"
        case confidence
        case ingredients
        case totals
    }
}

struct IngredientData: Codable {
    let name: String
    let quantity: Double
    let unit: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
}

struct NutritionData: Codable {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
}