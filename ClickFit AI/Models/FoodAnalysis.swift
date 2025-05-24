import Foundation

struct FoodAnalysis: Codable, Identifiable {
    let id: UUID
    let date: Date
    let mealName: String
    let imageData: Data?
    var totalCalories: Int
    let confidence: Double
    var ingredients: [Ingredient]
    var totals: NutritionInfo
    
    init(id: UUID = UUID(), 
         date: Date = Date(), 
         mealName: String, 
         imageData: Data? = nil,
         totalCalories: Int, 
         confidence: Double, 
         ingredients: [Ingredient], 
         totals: NutritionInfo) {
        self.id = id
        self.date = date
        self.mealName = mealName
        self.imageData = imageData
        self.totalCalories = totalCalories
        self.confidence = confidence
        self.ingredients = ingredients
        self.totals = totals
    }
    
    // Recalculate totals when ingredients change
    mutating func recalculateTotals() {
        var newTotals = NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0)
        
        for ingredient in ingredients {
            newTotals.calories += ingredient.calories
            newTotals.protein += ingredient.protein
            newTotals.carbs += ingredient.carbs
            newTotals.fat += ingredient.fat
        }
        
        self.totals = newTotals
        self.totalCalories = newTotals.calories
    }
}