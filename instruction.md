# ClickFit AI - Product Requirements Document

## Product Overview
ClickFit AI is an iOS application that uses AI-powered image recognition to analyze food photos and provide detailed nutritional information. Users can take photos of their meals, receive instant calorie and nutrient breakdowns, edit the analysis, and track their dietary history.

## Core Features

### 1. Camera Capture
- **Primary Function**: Take photos of food items
- **Requirements**:
  - Access device camera (request permissions)
  - Support both photo capture and gallery selection
  - Real-time camera preview
  - Auto-focus and exposure adjustment
  - Image compression before API submission (max 1MB)

### 2. AI Food Analysis
- **Primary Function**: Analyze food photos using OpenAI Vision API
- **Requirements**:
  - Send compressed image to OpenAI Vision API
  - Parse structured JSON response
  - Display loading state during analysis
  - Handle API errors gracefully
  - Show confidence levels for predictions

### 3. Ingredient Editor
- **Primary Function**: Allow users to edit AI-generated results
- **Requirements**:
  - List all detected ingredients
  - Edit quantities and portions
  - Add/remove ingredients
  - Real-time calorie recalculation
  - Save custom modifications

### 4. History & Calendar
- **Primary Function**: Track meal history over time
- **Requirements**:
  - Calendar view showing logged meals
  - Daily/weekly/monthly summaries
  - Search and filter capabilities
  - Export data functionality
  - Local data persistence

## Technical Specifications

### API Integration

#### OpenAI Vision API Request
```json
{
  "model": "gpt-4-vision-preview",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Analyze this food image and return a JSON with ingredients and nutritional information"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,{base64_image}"
          }
        }
      ]
    }
  ],
  "max_tokens": 1000,
  "response_format": { "type": "json_object" }
}
```

#### Expected JSON Response Structure
```json
{
  "meal_name": "Grilled Chicken Salad",
  "total_calories": 450,
  "confidence": 0.85,
  "ingredients": [
    {
      "name": "Grilled Chicken Breast",
      "quantity": 150,
      "unit": "grams",
      "calories": 247,
      "protein": 46.4,
      "carbs": 0,
      "fat": 5.4
    },
    {
      "name": "Mixed Greens",
      "quantity": 100,
      "unit": "grams",
      "calories": 20,
      "protein": 2.2,
      "carbs": 3.7,
      "fat": 0.2
    }
  ],
  "totals": {
    "calories": 450,
    "protein": 52.3,
    "carbs": 15.2,
    "fat": 12.5
  }
}
```

### Data Models

#### FoodAnalysis
```swift
struct FoodAnalysis: Codable, Identifiable {
    let id: UUID
    let date: Date
    let mealName: String
    let imageData: Data?
    let totalCalories: Int
    let confidence: Double
    let ingredients: [Ingredient]
    let totals: NutritionInfo
}
```

#### Ingredient
```swift
struct Ingredient: Codable, Identifiable {
    let id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
}
```

#### NutritionInfo
```swift
struct NutritionInfo: Codable {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
}
```

## User Interface Design

### Screen Flow
1. **Launch Screen** → Camera View
2. **Camera View** → Analysis Loading → Results View
3. **Results View** → Edit Ingredients or Save
4. **Tab Bar**: Camera | History | Settings

### Design Guidelines
- Use iOS native design patterns
- Support Dark Mode
- Implement haptic feedback
- Smooth animations (0.3s standard)
- Accessibility support (VoiceOver)

### Color Scheme
- Primary: System Blue
- Success: System Green
- Warning: System Orange
- Error: System Red
- Background: System Background

## Performance Requirements
- Camera launch: < 1 second
- Image capture: Instant
- API response: < 3 seconds
- Local data operations: < 100ms
- App launch: < 2 seconds

## Error Handling

### Network Errors
- No internet connection
- API timeout (30 seconds)
- Invalid API key
- Rate limiting

### Camera Errors
- Permission denied
- Camera unavailable
- Storage full

### Data Errors
- Corrupted local data
- Invalid JSON response
- Missing required fields

## Security & Privacy
- API key stored in Keychain
- Images compressed and deleted after analysis
- Local data encrypted
- Privacy policy compliance
- HTTPS only communications

## Future Enhancements (Post-MVP)
- Barcode scanning
- Recipe suggestions
- Meal planning
- Social sharing
- Apple Health integration
- Dietary restrictions support
- Multiple language support

## Success Metrics
- Successful API integration
- Accurate food detection (>80%)
- Smooth user experience
- Clean code architecture
- Comprehensive error handling