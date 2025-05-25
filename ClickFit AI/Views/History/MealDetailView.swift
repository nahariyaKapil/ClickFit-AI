import SwiftUI

struct MealDetailView: View {
    let analysis: FoodAnalysis
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var shareText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color.black
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Text("Meal Details")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white.opacity(0.5))
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 60)
                        .padding(.bottom, 10)
                        
                        // Meal Image if available
                        if let imageData = analysis.imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                .padding(.horizontal, 20)
                        }
                        
                        // Meal Info Card
                        VStack(spacing: 15) {
                            Text(analysis.mealName)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 20) {
                                HStack(spacing: 5) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 14))
                                        .foregroundColor(.cyan)
                                    Text(analysis.date.formatted(as: "MMM d, yyyy"))
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                HStack(spacing: 5) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 14))
                                        .foregroundColor(.cyan)
                                    Text(analysis.date.formatted(as: "h:mm a"))
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            
                            if analysis.confidence > 0 {
                                HStack(spacing: 5) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.green)
                                    Text("\(Int(analysis.confidence * 100))% Confidence")
                                        .font(.system(size: 14))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding(.vertical, 20)
                        
                        // Nutrition Summary
                        ModernNutritionSummaryCard(
                            protein: analysis.totals.protein,
                            carbs: analysis.totals.carbs,
                            fat: analysis.totals.fat
                        )
                        .padding(.horizontal, 20)
                        
                        // Ingredients List
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Ingredients")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 25)
                            
                            ForEach(analysis.ingredients) { ingredient in
                                ModernIngredientCard(ingredient: ingredient)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 20)
                        
                        // Export Button
                        Button(action: {
                            prepareExportText()
                            showingShareSheet = true
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18))
                                Text("Export Meal Data")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingShareSheet) {
            ActivityViewController(activityItems: [shareText])
        }
    }
    
    private func prepareExportText() {
        shareText = "🍽️ ClickFit AI - Meal Analysis\n\n"
        shareText += "Meal: \(analysis.mealName)\n"
        shareText += "Date: \(analysis.date.formatted(date: .abbreviated, time: .shortened))\n"
        shareText += "Total Calories: \(analysis.totalCalories) kcal\n\n"
        shareText += "📊 Nutritional Breakdown:\n"
        shareText += "• Protein: \(analysis.totals.formattedProtein)g\n"
        shareText += "• Carbohydrates: \(analysis.totals.formattedCarbs)g\n"
        shareText += "• Fat: \(analysis.totals.formattedFat)g\n\n"
        shareText += "🥘 Ingredients:\n"
        
        for ingredient in analysis.ingredients {
            shareText += "• \(ingredient.name): \(String(format: "%.1f", ingredient.quantity)) \(ingredient.unit) (\(ingredient.calories) cal)\n"
        }
        
        shareText += "\n💪 Tracked with ClickFit AI"
    }
}

// MARK: - Modern Nutrition Summary Card
struct ModernNutritionSummaryCard: View {
    let protein: Double
    let carbs: Double
    let fat: Double
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Nutrition Summary")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack(spacing: 15) {
                NutritionItemView(
                    value: String(format: "%.1f", protein),
                    label: "Protein",
                    unit: "g",
                    color: .blue,
                    icon: "p.circle.fill"
                )
                
                NutritionItemView(
                    value: String(format: "%.1f", carbs),
                    label: "Carbs",
                    unit: "g",
                    color: .orange,
                    icon: "c.circle.fill"
                )
                
                NutritionItemView(
                    value: String(format: "%.1f", fat),
                    label: "Fat",
                    unit: "g",
                    color: .green,
                    icon: "f.circle.fill"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Nutrition Item View
struct NutritionItemView: View {
    let value: String
    let label: String
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.2))
        )
    }
}

// MARK: - Modern Ingredient Card
struct ModernIngredientCard: View {
    let ingredient: Ingredient
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(ingredient.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text("\(ingredient.quantity, specifier: "%.1f") \(ingredient.unit)")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text("\(ingredient.calories)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)
                
                Text("cal")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 8) {
                    MacroTag(value: ingredient.protein, label: "P", color: .blue)
                    MacroTag(value: ingredient.carbs, label: "C", color: .orange)
                    MacroTag(value: ingredient.fat, label: "F", color: .green)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.04)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Macro Tag
struct MacroTag: View {
    let value: Double
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
            Text("\(value, specifier: "%.1f")")
                .font(.system(size: 10))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.2))
        )
    }
}

// MARK: - Activity View Controller
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}