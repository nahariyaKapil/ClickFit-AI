import Foundation
import UIKit
import Network

enum OpenAIError: LocalizedError {
    case invalidAPIKey
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case imageTooLarge
    case rateLimitExceeded
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your OpenAI API key in Settings."
        case .invalidResponse:
            return "Invalid response from OpenAI API."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to parse the response. Please try again."
        case .imageTooLarge:
            return "Image is too large. Please try with a smaller image."
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .noInternetConnection:
            return "No internet connection. Please check your network and try again."
        }
    }
}

@MainActor
class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    
    private let apiKeyManager = APIKeyManager.shared
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let maxImageSize: Int = 1_048_576 // 1MB in bytes
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "NetworkMonitor")
    @Published var isNetworkAvailable = true
    
    init() {
        startNetworkMonitoring()
        print("🚀 OpenAIService initialized with APIKeyManager")
    }
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: networkQueue)
    }
    
    func updateAPIKey(_ newKey: String) {
        print("🔄 OpenAIService updating API key via manager...")
        apiKeyManager.saveAPIKey(newKey)
    }
    
    func hasValidAPIKey() -> Bool {
        let hasValid = apiKeyManager.hasValidAPIKey()
        print("🔍 OpenAIService hasValidAPIKey: \(hasValid)")
        return hasValid
    }
    
    func getCurrentAPIKey() -> String {
        return apiKeyManager.getAPIKey()
    }
    
    func analyzeFood(image: UIImage) async throws -> FoodAnalysis {
        print("🔄 Starting food analysis...")
        
        // Debug UserDefaults state
        apiKeyManager.debugUserDefaults()
        
        // Simple network check
        guard isNetworkAvailable else {
            print("❌ No network connection detected")
            throw OpenAIError.noInternetConnection
        }
        
        // Check if we have a valid API key
        if !hasValidAPIKey() {
            print("⚠️ No valid API key found, using mock data")
            return try await analyzeFoodMock(image: image)
        }
        
        print("✅ Valid API key found, proceeding with real analysis")
        
        // Compress image
        guard let imageData = compressImage(image) else {
            throw OpenAIError.imageTooLarge
        }
        
        print("📷 Compressed image size: \(imageData.count) bytes")
        
        // Convert to base64
        let base64Image = imageData.base64EncodedString()
        print("🔄 Image converted to base64")
        
        // Create request
        let request = createRequest(base64Image: base64Image)
        print("📤 API request created")
        
        // Perform API call with retry logic
        let analysisResult = try await performRequestWithRetry(request)
        print("✅ Analysis completed successfully")
        
        // Convert to FoodAnalysis
        return convertToFoodAnalysis(from: analysisResult, imageData: imageData)
    }
    
    private func compressImage(_ image: UIImage) -> Data? {
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)
        
        // Reduce quality until under size limit
        while let data = imageData, data.count > maxImageSize && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        // If still too large, resize the image
        if let data = imageData, data.count > maxImageSize {
            let resizedImage = resizeImage(image, targetSize: CGSize(width: 1024, height: 1024))
            imageData = resizedImage.jpegData(compressionQuality: 0.8)
        }
        
        return imageData
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    private func createRequest(base64Image: String) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        
        let apiKey = getCurrentAPIKey()
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60.0
        
        print("🔑 Using API key for request: \(apiKey.prefix(10))...")
        
        let prompt = """
        Analyze this food image and provide a detailed nutritional breakdown. 
        Return ONLY a valid JSON object with the following structure:
        {
            "meal_name": "descriptive name of the meal",
            "total_calories": total calories as integer,
            "confidence": confidence level between 0 and 1,
            "ingredients": [
                {
                    "name": "ingredient name",
                    "quantity": amount as number,
                    "unit": "grams/cups/pieces/etc",
                    "calories": calories as integer,
                    "protein": protein in grams,
                    "carbs": carbohydrates in grams,
                    "fat": fat in grams
                }
            ],
            "totals": {
                "calories": total calories,
                "protein": total protein in grams,
                "carbs": total carbs in grams,
                "fat": total fat in grams
            }
        }
        Be as accurate as possible with portion sizes and nutritional values. Return only valid JSON, no additional text.
        """
        
        let openAIRequest = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                Message(
                    role: "user",
                    content: [
                        Content(type: "text", text: prompt, imageUrl: nil),
                        Content(type: "image_url", text: nil, imageUrl: ImageURL(url: "data:image/jpeg;base64,\(base64Image)"))
                    ]
                )
            ],
            maxTokens: 1000,
            responseFormat: ResponseFormat(type: "json_object")
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(openAIRequest)
            print("📤 Request body encoded successfully")
        } catch {
            print("❌ Error encoding request: \(error)")
        }
        
        return request
    }
    
    private func performRequestWithRetry(_ request: URLRequest, maxRetries: Int = 2) async throws -> AnalysisResult {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                print("🔄 Attempt \(attempt)/\(maxRetries)")
                return try await performRequest(request)
            } catch {
                lastError = error
                print("❌ Attempt \(attempt) failed: \(error.localizedDescription)")
                
                // Don't retry for certain errors
                if case OpenAIError.invalidAPIKey = error,
                   case OpenAIError.rateLimitExceeded = error {
                    throw error
                }
                
                // Wait before retrying (simple 2 second delay)
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    print("⏳ Retrying in 2 seconds...")
                }
            }
        }
        
        throw lastError ?? OpenAIError.networkError(NSError(domain: "Unknown", code: -1))
    }
    
    private func performRequest(_ request: URLRequest) async throws -> AnalysisResult {
        print("📡 Making API request to OpenAI...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Log response for debugging
        let responseString = String(data: data, encoding: .utf8) ?? "Invalid UTF-8"
        print("📥 Raw API response: \(responseString.prefix(500))...")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw OpenAIError.invalidResponse
        }
        
        print("📊 HTTP Status Code: \(httpResponse.statusCode)")
        
        switch httpResponse.statusCode {
        case 200:
            return try decodeResponse(from: data)
        case 401:
            print("❌ API key is invalid")
            throw OpenAIError.invalidAPIKey
        case 429:
            print("❌ Rate limit exceeded")
            throw OpenAIError.rateLimitExceeded
        default:
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Error Response (\(httpResponse.statusCode)): \(errorMsg)")
            throw OpenAIError.networkError(NSError(domain: "OpenAI", code: httpResponse.statusCode))
        }
    }
    
    private func decodeResponse(from data: Data) throws -> AnalysisResult {
        do {
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            print("✅ OpenAI response decoded successfully")
            
            guard let content = openAIResponse.choices.first?.message.content else {
                print("❌ No content in OpenAI response")
                throw OpenAIError.invalidResponse
            }
            
            print("📄 Analysis content: \(content.prefix(200))...")
            
            // Clean the JSON content (remove any markdown formatting)
            let cleanedContent = content
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let cleanedData = cleanedContent.data(using: .utf8) else {
                throw OpenAIError.invalidResponse
            }
            
            let result = try JSONDecoder().decode(AnalysisResult.self, from: cleanedData)
            print("✅ Analysis result decoded successfully")
            return result
        } catch {
            print("❌ Decoding error: \(error)")
            throw OpenAIError.decodingError(error)
        }
    }
    
    private func convertToFoodAnalysis(from result: AnalysisResult, imageData: Data) -> FoodAnalysis {
        let ingredients = result.ingredients.map { ingredientData in
            Ingredient(
                name: ingredientData.name,
                quantity: ingredientData.quantity,
                unit: ingredientData.unit,
                calories: ingredientData.calories,
                protein: ingredientData.protein,
                carbs: ingredientData.carbs,
                fat: ingredientData.fat
            )
        }
        
        let totals = NutritionInfo(
            calories: result.totals.calories,
            protein: result.totals.protein,
            carbs: result.totals.carbs,
            fat: result.totals.fat
        )
        
        return FoodAnalysis(
            mealName: result.mealName,
            imageData: imageData,
            totalCalories: result.totalCalories,
            confidence: result.confidence,
            ingredients: ingredients,
            totals: totals
        )
    }
}

// MARK: - Mock Service for Testing
extension OpenAIService {
    func analyzeFoodMock(image: UIImage) async throws -> FoodAnalysis {
        print("🎭 Using mock data for analysis")
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Return mock data based on image analysis
        let ingredients = [
            Ingredient(
                name: "Grilled Chicken Breast",
                quantity: 150,
                unit: "grams",
                calories: 247,
                protein: 46.4,
                carbs: 0,
                fat: 5.4
            ),
            Ingredient(
                name: "Mixed Greens",
                quantity: 100,
                unit: "grams",
                calories: 20,
                protein: 2.2,
                carbs: 3.7,
                fat: 0.2
            ),
            Ingredient(
                name: "Cherry Tomatoes",
                quantity: 50,
                unit: "grams",
                calories: 9,
                protein: 0.4,
                carbs: 1.9,
                fat: 0.1
            ),
            Ingredient(
                name: "Olive Oil Dressing",
                quantity: 15,
                unit: "ml",
                calories: 124,
                protein: 0,
                carbs: 0,
                fat: 14
            )
        ]
        
        let totals = NutritionInfo(
            calories: 400,
            protein: 49.0,
            carbs: 5.6,
            fat: 19.7
        )
        
        return FoodAnalysis(
            mealName: "Grilled Chicken Salad (Demo)",
            imageData: image.jpegData(compressionQuality: 0.8),
            totalCalories: 400,
            confidence: 0.92,
            ingredients: ingredients,
            totals: totals
        )
    }
}