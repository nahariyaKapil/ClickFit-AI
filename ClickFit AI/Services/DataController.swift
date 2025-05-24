import CoreData

@MainActor
class DataController: ObservableObject {
    @Published var savedAnalyses: [FoodAnalysis] = []
    
    private let userDefaults = UserDefaults.standard
    private let analysesKey = "SavedFoodAnalyses"
    
    init() {
        loadAnalyses()
    }
    
    func save(_ analysis: FoodAnalysis) {
        savedAnalyses.append(analysis)
        saveAnalyses()
    }
    
    func update(_ analysis: FoodAnalysis) {
        if let index = savedAnalyses.firstIndex(where: { $0.id == analysis.id }) {
            savedAnalyses[index] = analysis
            saveAnalyses()
        }
    }
    
    func delete(_ analysis: FoodAnalysis) {
        savedAnalyses.removeAll { $0.id == analysis.id }
        saveAnalyses()
    }
    
    private func saveAnalyses() {
        if let encoded = try? JSONEncoder().encode(savedAnalyses) {
            userDefaults.set(encoded, forKey: analysesKey)
        }
    }
    
    private func loadAnalyses() {
        if let data = userDefaults.data(forKey: analysesKey),
           let decoded = try? JSONDecoder().decode([FoodAnalysis].self, from: data) {
            savedAnalyses = decoded
        }
    }
    
    // Helper methods for history view
    func analyses(for date: Date) -> [FoodAnalysis] {
        let calendar = Calendar.current
        return savedAnalyses.filter { analysis in
            calendar.isDate(analysis.date, inSameDayAs: date)
        }
    }
    
    func totalCalories(for date: Date) -> Int {
        analyses(for: date).reduce(0) { $0 + $1.totalCalories }
    }
    
    func weeklyCalories() -> [(date: Date, calories: Int)] {
        let calendar = Calendar.current
        let today = Date()
        var results: [(Date, Int)] = []
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let calories = totalCalories(for: date)
                results.append((date, calories))
            }
        }
        
        return results.reversed()
    }
}