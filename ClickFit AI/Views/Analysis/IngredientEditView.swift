import SwiftUI

struct IngredientEditView: View {
    @State private var ingredient: Ingredient
    let onSave: (Ingredient) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(ingredient: Ingredient, onSave: @escaping (Ingredient) -> Void) {
        self._ingredient = State(initialValue: ingredient)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $ingredient.name)
                    
                    HStack {
                        TextField("Quantity", value: $ingredient.quantity, format: .number)
                            .keyboardType(.decimalPad)
                        
                        TextField("Unit", text: $ingredient.unit)
                            .frame(maxWidth: 100)
                    }
                }
                
                Section(header: Text("Nutrition Information")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", value: $ingredient.calories, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("cal")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0.0", value: $ingredient.protein, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("0.0", value: $ingredient.carbs, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("0.0", value: $ingredient.fat, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(ingredient)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}