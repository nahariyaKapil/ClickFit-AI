import Foundation

@MainActor
class APIKeyManager: ObservableObject {
    static let shared = APIKeyManager()
    
    private static let storageKey = "OpenAI_API_Key"
    
    @Published var currentAPIKey: String = ""
    @Published var isValid: Bool = false
    
    private init() {
        loadAPIKey()
        print("🔑 APIKeyManager initialized with key: \(currentAPIKey.prefix(10))... (length: \(currentAPIKey.count))")
    }
    
    private func loadAPIKey() {
        currentAPIKey = UserDefaults.standard.string(forKey: Self.storageKey) ?? ""
        validateKey()
        print("📖 Loaded API key: \(currentAPIKey.prefix(10))... (length: \(currentAPIKey.count))")
    }
    
    private func validateKey() {
        isValid = !currentAPIKey.isEmpty && currentAPIKey.hasPrefix("sk-") && currentAPIKey.count >= 20
        print("✅ Key validation: \(isValid ? "VALID" : "INVALID")")
    }
    
    func saveAPIKey(_ key: String) {
        print("💾 Saving API key: \(key.prefix(10))... (length: \(key.count))")
        
        currentAPIKey = key
        
        if key.isEmpty {
            UserDefaults.standard.removeObject(forKey: Self.storageKey)
            print("🗑️ Removed API key from storage")
        } else {
            UserDefaults.standard.set(key, forKey: Self.storageKey)
            print("💾 Saved API key to UserDefaults")
        }
        
        // Force sync
        UserDefaults.standard.synchronize()
        
        // Validate the key
        validateKey()
        
        // Verify save
        let savedKey = UserDefaults.standard.string(forKey: Self.storageKey) ?? ""
        print("🔍 Verification - Saved key: \(savedKey.prefix(10))... (length: \(savedKey.count))")
        
        if savedKey == key {
            print("✅ API key save verification: SUCCESS")
        } else {
            print("❌ API key save verification: FAILED")
        }
    }
    
    func getAPIKey() -> String {
        // Always get fresh from UserDefaults
        let freshKey = UserDefaults.standard.string(forKey: Self.storageKey) ?? ""
        
        if freshKey != currentAPIKey {
            print("🔄 Key mismatch detected, updating: \(freshKey.prefix(10))... vs \(currentAPIKey.prefix(10))...")
            currentAPIKey = freshKey
            validateKey()
        }
        
        print("🎯 Returning API key: \(currentAPIKey.prefix(10))... (length: \(currentAPIKey.count))")
        return currentAPIKey
    }
    
    func hasValidAPIKey() -> Bool {
        let key = getAPIKey()
        let valid = !key.isEmpty && key.hasPrefix("sk-") && key.count >= 20
        print("🔍 hasValidAPIKey check: \(valid ? "VALID" : "INVALID") for key: \(key.prefix(10))... (length: \(key.count))")
        return valid
    }
    
    func clearAPIKey() {
        saveAPIKey("")
    }
    
    // Debug function to check UserDefaults state
    func debugUserDefaults() {
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let openAIKeys = allKeys.filter { $0.contains("OpenAI") }
        print("🔍 Debug: All UserDefaults keys containing 'OpenAI': \(openAIKeys)")
        
        if let directKey = UserDefaults.standard.string(forKey: Self.storageKey) {
            print("🔍 Debug: Direct UserDefaults lookup: \(directKey.prefix(10))... (length: \(directKey.count))")
        } else {
            print("🔍 Debug: Direct UserDefaults lookup: NO KEY FOUND")
        }
    }
}