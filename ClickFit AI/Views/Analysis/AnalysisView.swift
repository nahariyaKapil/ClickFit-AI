import SwiftUI

struct AnalysisView: View {
    let image: UIImage
    let onSave: (FoodAnalysis) -> Void
    
    @StateObject private var viewModel = AnalysisViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var editingIngredient: Ingredient?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading {
                    // Loading View
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        
                        Text("Analyzing your meal...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("This may take a few seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                } else if let analysis = viewModel.analysis {
                    // Results View
                    ScrollView {
                        VStack(spacing: 20) {
                            // Food Image
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            
                            // Meal Name and Confidence
                            VStack(spacing: 8) {
                                Text(analysis.mealName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                HStack {
                                    Image(systemName: "checkmark.shield.fill")
                                        .foregroundColor(.green)
                                    Text("\(Int(analysis.confidence * 100))% Confidence")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Nutrition Summary Card
                            NutritionSummaryCard(nutrition: analysis.totals)
                                .padding(.horizontal)
                            
                            // Ingredients List
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Ingredients")
                                        .font(.headline)
                                    Spacer()
                                    Button(action: {
                                        viewModel.addNewIngredient()
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.horizontal)
                                
                                ForEach(analysis.ingredients) { ingredient in
                                    IngredientRow(
                                        ingredient: ingredient,
                                        onEdit: {
                                            editingIngredient = ingredient
                                            showingEditSheet = true
                                        },
                                        onDelete: {
                                            viewModel.deleteIngredient(ingredient)
                                        }
                                    )
                                }
                            }
                            .padding(.vertical)
                        }
                        .padding(.bottom, 100) // Space for save button
                    }
                    
                    // Save Button
                    VStack {
                        Spacer()
                        Button(action: {
                            onSave(analysis)
                            dismiss()
                        }) {
                            Text("Save Meal")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                    }
                }
            }
            .navigationBarTitle("Analysis Results", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Retry") {
                    Task { await viewModel.analyzeImage(image) }
                }.opacity(viewModel.error != nil ? 1 : 0)
            )
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An error occurred")
            }
            .sheet(isPresented: $showingEditSheet) {
                if let ingredient = editingIngredient {
                    IngredientEditView(
                        ingredient: ingredient,
                        onSave: { updated in
                            viewModel.updateIngredient(updated)
                            showingEditSheet = false
                        }
                    )
                }
            }
        }
        .task {
            await viewModel.analyzeImage(image)
        }
    }
}

// MARK: - Nutrition Summary Card
struct NutritionSummaryCard: View {
    let nutrition: NutritionInfo
    
    var body: some View {
        VStack(spacing: 15) {
            Text("\(nutrition.calories)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Total Calories")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 30) {
                NutrientLabel(
                    title: "Protein",
                    value: nutrition.formattedProtein,
                    unit: "g",
                    color: .blue
                )
                
                NutrientLabel(
                    title: "Carbs",
                    value: nutrition.formattedCarbs,
                    unit: "g",
                    color: .orange
                )
                
                NutrientLabel(
                    title: "Fat",
                    value: nutrition.formattedFat,
                    unit: "g",
                    color: .green
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
    }
}

// MARK: - Nutrient Label
struct NutrientLabel: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Ingredient Row
struct IngredientRow: View {
    let ingredient: Ingredient
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack {
                    Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(ingredient.calories) cal")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Analysis ViewModel
@MainActor
class AnalysisViewModel: ObservableObject {
    @Published var analysis: FoodAnalysis?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let openAIService = OpenAIService.shared
    
    func analyzeImage(_ image: UIImage) async {
        isLoading = true
        error = nil
        
        do {
            // Try real API first, falls back to mock if no API key
            analysis = try await openAIService.analyzeFood(image: image)
        } catch {
            self.error = error
            print("Analysis error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func updateIngredient(_ updated: Ingredient) {
        guard var analysis = analysis,
              let index = analysis.ingredients.firstIndex(where: { $0.id == updated.id }) else {
            return
        }
        
        analysis.ingredients[index] = updated
        analysis.recalculateTotals()
        self.analysis = analysis
    }
    
    func deleteIngredient(_ ingredient: Ingredient) {
        guard var analysis = analysis else { return }
        
        analysis.ingredients.removeAll { $0.id == ingredient.id }
        analysis.recalculateTotals()
        self.analysis = analysis
    }
    
    func addNewIngredient() {
        guard var analysis = analysis else { return }
        
        let newIngredient = Ingredient(
            name: "New Ingredient",
            quantity: 100,
            unit: "grams",
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0
        )
        
        analysis.ingredients.append(newIngredient)
        self.analysis = analysis
    }
}