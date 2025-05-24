import Foundation

struct Ingredient: Codable, Identifiable {
    let id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    
    init(id: UUID = UUID(),
         name: String,
         quantity: Double,
         unit: String,
         calories: Int,
         protein: Double,
         carbs: Double,
         fat: Double) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
}