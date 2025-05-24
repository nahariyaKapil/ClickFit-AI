import SwiftUI

struct MealDetailView: View {
    let analysis: FoodAnalysis
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Meal Image if available
                    if let imageData = analysis.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    
                    // Meal Info
                    VStack(spacing: 10) {
                        Text(analysis.mealName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label(analysis.date.formatted(as: "MMM d, yyyy"), systemImage: "calendar")
                            Text("•")
                            Label(analysis.date.formatted(as: "h:mm a"), systemImage: "clock")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        if analysis.confidence > 0 {
                            HStack {
                                Image(systemName: "checkmark.shield.fill")
                                    .foregroundColor(.green)
                                Text("\(Int(analysis.confidence * 100))% Confidence")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Nutrition Summary
                    NutritionSummaryCard(nutrition: analysis.totals)
                        .padding(.horizontal)
                    
                    // Ingredients List
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Ingredients")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(analysis.ingredients) { ingredient in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(ingredient.name)
                                        .font(.body)
                                    
                                    Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(ingredient.calories) cal")
                                        .font(.callout)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                    
                                    HStack(spacing: 10) {
                                        MacroText(value: ingredient.protein, label: "P", color: .blue)
                                        MacroText(value: ingredient.carbs, label: "C", color: .orange)
                                        MacroText(value: ingredient.fat, label: "F", color: .green)
                                    }
                                    .font(.caption2)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    
                    // Export Button
                    Button(action: exportMeal) {
                        Label("Export Meal Data", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Meal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func exportMeal() {
        // Create shareable text
        var text = "Meal: \(analysis.mealName)\n"
        text += "Date: \(analysis.date.formatted())\n"
        text += "Total Calories: \(analysis.totalCalories)\n\n"
        text += "Macros:\n"
        text += "- Protein: \(analysis.totals.formattedProtein)g\n"
        text += "- Carbs: \(analysis.totals.formattedCarbs)g\n"
        text += "- Fat: \(analysis.totals.formattedFat)g\n\n"
        text += "Ingredients:\n"
        
        for ingredient in analysis.ingredients {
            text += "- \(ingredient.name): \(ingredient.quantity) \(ingredient.unit) (\(ingredient.calories) cal)\n"
        }
        
        // Show share sheet
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(av, animated: true)
        }
    }
}

struct MacroText: View {
    let value: Double
    let label: String
    let color: Color
    
    var body: some View {
        Text("\(label):\(value, specifier: "%.1f")")
            .foregroundColor(color)
    }
}