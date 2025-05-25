import SwiftUI

struct SettingsView: View {
    @StateObject private var apiKeyManager = APIKeyManager.shared
    @StateObject private var openAIService = OpenAIService.shared
    @State private var apiKey: String = ""
    @State private var showingAPIKeyInfo = false
    @State private var hasUnsavedChanges = false
    @State private var showingClearConfirmation = false
    @State private var showingPrivacyPolicy = false
    @State private var showingHelpSupport = false
    @State private var userRating: Int = 0
    @State private var hasRated = false
    @State private var showingRatingPopup = false
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
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
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header - Removed Done button
                        HStack {
                            Text("Settings")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                        
                        // App Info Card
                        ModernAppInfoCard()
                            .padding(.horizontal, 20)
                        
                        // API Configuration Card
                        ModernAPIConfigCard(
                            apiKey: $apiKey,
                            hasUnsavedChanges: $hasUnsavedChanges,
                            showingAPIKeyInfo: $showingAPIKeyInfo,
                            showingClearConfirmation: $showingClearConfirmation,
                            isTextFieldFocused: $isTextFieldFocused,
                            apiKeyManager: apiKeyManager,
                            saveAction: saveAPIKey,
                            clearAction: clearAPIKey
                        )
                        .padding(.horizontal, 20)
                        
                        // Support Section
                        ModernSupportSection(
                            showingPrivacyPolicy: $showingPrivacyPolicy,
                            showingHelpSupport: $showingHelpSupport,
                            showingRatingPopup: $showingRatingPopup,
                            userRating: userRating,
                            hasRated: hasRated
                        )
                        .padding(.horizontal, 20)
                        
                        // App Information
                        ModernAppInfoSection()
                            .padding(.horizontal, 20)
                        
                        // Made with Love
                        MadeWithLove()
                            .padding(.top, 30)
                            .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadCurrentAPIKey()
                loadUserRating()
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
            .alert("Get OpenAI API Key", isPresented: $showingAPIKeyInfo) {
                Button("Get API Key") {
                    if let url = URL(string: "https://platform.openai.com/api-keys") {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("To use real AI food analysis, you need an OpenAI API key. Visit platform.openai.com to create an account and get your API key. The app works great with demo data if you prefer not to use an API key.")
            }
            .alert("Remove API Key", isPresented: $showingClearConfirmation) {
                Button("Remove", role: .destructive) {
                    clearAPIKey()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to remove your API key? The app will use demo data for analysis.")
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingHelpSupport) {
                HelpSupportView()
            }
            .sheet(isPresented: $showingRatingPopup) {
                RatingPopupView(userRating: $userRating, hasRated: $hasRated)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func loadCurrentAPIKey() {
        apiKey = apiKeyManager.currentAPIKey
        hasUnsavedChanges = false
    }
    
    private func loadUserRating() {
        userRating = UserDefaults.standard.integer(forKey: "userRating")
        hasRated = userRating > 0
    }
    
    private func saveAPIKey() {
        apiKeyManager.saveAPIKey(apiKey)
        hasUnsavedChanges = false
        apiKeyManager.debugUserDefaults()
    }
    
    private func clearAPIKey() {
        apiKey = ""
        hasUnsavedChanges = false
        apiKeyManager.clearAPIKey()
    }
}

// MARK: - Modern App Info Card
struct ModernAppInfoCard: View {
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.cyan, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 5)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(animate ? 5 : -5))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("ClickFit AI")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("AI-Powered Nutrition Analysis")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
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
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Modern API Config Card
struct ModernAPIConfigCard: View {
    @Binding var apiKey: String
    @Binding var hasUnsavedChanges: Bool
    @Binding var showingAPIKeyInfo: Bool
    @Binding var showingClearConfirmation: Bool
    @FocusState.Binding var isTextFieldFocused: Bool
    let apiKeyManager: APIKeyManager
    let saveAction: () -> Void
    let clearAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("API Configuration", systemImage: "key.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showingAPIKeyInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.cyan)
                }
            }
            
            VStack(spacing: 12) {
                // API Key Input Field
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white.opacity(0.5))
                    
                    TextField("Enter OpenAI API key (sk-...)", text: $apiKey)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isTextFieldFocused)
                        .onChange(of: apiKey) { _, newValue in
                            hasUnsavedChanges = (newValue != apiKeyManager.currentAPIKey)
                        }
                        .onSubmit {
                            isTextFieldFocused = false
                            if hasUnsavedChanges {
                                saveAction()
                            }
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isTextFieldFocused ? Color.cyan : Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                
                // Action Buttons
                HStack {
                    if !apiKey.isEmpty {
                        Button("Clear") {
                            showingClearConfirmation = true
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    StatusIndicator(
                        hasUnsavedChanges: hasUnsavedChanges,
                        isValid: apiKeyManager.isValid,
                        apiKey: apiKey
                    )
                    
                    Button(action: {
                        isTextFieldFocused = false
                        saveAction()
                    }) {
                        Text("Save")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .opacity(hasUnsavedChanges ? 1 : 0.5)
                            )
                            .cornerRadius(20)
                    }
                    .disabled(!hasUnsavedChanges)
                }
                
                // Status Messages
                APIStatusMessage(apiKey: apiKey, isValid: apiKeyManager.isValid, hasUnsavedChanges: hasUnsavedChanges)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
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
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Status Indicator
struct StatusIndicator: View {
    let hasUnsavedChanges: Bool
    let isValid: Bool
    let apiKey: String
    
    var body: some View {
        if hasUnsavedChanges {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
                Text("Unsaved")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
            }
        } else if isValid && !apiKey.isEmpty {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.green)
                Text("Saved")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
            }
        }
    }
}

// MARK: - API Status Message
struct APIStatusMessage: View {
    let apiKey: String
    let isValid: Bool
    let hasUnsavedChanges: Bool
    
    private func isValidAPIKey(_ key: String) -> Bool {
        return !key.isEmpty && key.hasPrefix("sk-") && key.count >= 20
    }
    
    var body: some View {
        if apiKey.isEmpty {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("No API key configured")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.orange)
                    
                    Text("The app will use demo data for food analysis. Add an API key to get real AI-powered nutrition analysis.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        } else if !isValidAPIKey(apiKey) {
            HStack(spacing: 10) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                
                Text("API key should start with 'sk-' and be at least 20 characters long.")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else if !hasUnsavedChanges && isValid {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.green)
                
                Text("API key is saved! Real AI analysis is enabled.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.green)
            }
        }
    }
}

// MARK: - Modern Support Section
struct ModernSupportSection: View {
    @Binding var showingPrivacyPolicy: Bool
    @Binding var showingHelpSupport: Bool
    @Binding var showingRatingPopup: Bool
    let userRating: Int
    let hasRated: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Support", icon: "questionmark.circle")
            
            ModernSettingsRow(
                icon: "doc.text",
                title: "Privacy Policy",
                color: .blue,
                action: { showingPrivacyPolicy = true }
            )
            
            ModernSettingsRow(
                icon: "questionmark.circle",
                title: "Help & Support",
                color: .green,
                action: { showingHelpSupport = true }
            )
            
            ModernRatingRow(
                showingRatingPopup: $showingRatingPopup,
                userRating: userRating,
                hasRated: hasRated
            )
        }
    }
}

// MARK: - Modern Rating Row
struct ModernRatingRow: View {
    @Binding var showingRatingPopup: Bool
    let userRating: Int
    let hasRated: Bool
    @State private var isPressed = false
    
    var body: some View {
        HStack {
            Image(systemName: "star")
                .font(.system(size: 20))
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            Text("Rate This App")
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            if hasRated {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= userRating ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.3))
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            showingRatingPopup = true
        }
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Modern App Info Section
struct ModernAppInfoSection: View {
    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "App Information", icon: "info.circle")
            
            VStack(spacing: 12) {
                HStack {
                    Text("Version")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("1.0.0")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                HStack {
                    Text("Build")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("2025.05.24")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
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
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Made with Love for AppsClicks
struct MadeWithLove: View {
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Text("Made with")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.red)
                    .scaleEffect(animate ? 1.2 : 1.0)
                
                Text("for")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text("AppsClicks")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.cyan, Color.blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.top, 10)
    }
}

// MARK: - Modern Settings Row
struct ModernSettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.3))
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            action()
        }
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}