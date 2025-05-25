import SwiftUI

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        Text("Privacy Policy")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .padding(.top, 60)
                            .padding(.bottom, 20)
                        
                        // Content
                        VStack(alignment: .leading, spacing: 25) {
                            PolicySection(
                                title: "Information We Collect",
                                content: "ClickFit AI collects minimal information to provide you with the best experience. We collect photos of your meals for analysis, which are processed locally on your device. If you choose to use an API key, it is stored securely on your device."
                            )
                            
                            PolicySection(
                                title: "How We Use Your Information",
                                content: "• Meal photos are analyzed to provide nutritional information\n• API keys are used solely for connecting to OpenAI services\n• No personal data is transmitted without your explicit consent\n• All analysis happens on-device when using demo mode"
                            )
                            
                            PolicySection(
                                title: "Data Storage",
                                content: "All your data is stored locally on your device. We do not maintain servers or databases containing your personal information. Your meal history, photos, and settings remain private and under your control."
                            )
                            
                            PolicySection(
                                title: "Third-Party Services",
                                content: "If you choose to use an OpenAI API key, your meal photos may be sent to OpenAI for analysis. Please review OpenAI's privacy policy for information about how they handle data. Demo mode operates entirely offline."
                            )
                            
                            PolicySection(
                                title: "Your Rights",
                                content: "You have complete control over your data. You can:\n• Delete any meal record at any time\n• Remove your API key\n• Clear all app data through your device settings\n• Use the app in demo mode without any external connections"
                            )
                            
                            PolicySection(
                                title: "Contact Us",
                                content: "If you have any questions about this Privacy Policy, please contact us through the Help & Support section."
                            )
                            
                            // Last Updated
                            Text("Last updated: May 24, 2025")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 20)
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // Close Button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.5))
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }
                    Spacer()
                }
            )
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Policy Section
struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.cyan)
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(5)
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

// MARK: - Help & Support View
struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedSection: String? = nil
    
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
                        // Header
                        Text("Help & Support")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                            .padding(.top, 60)
                            .padding(.bottom, 20)
                        
                        // FAQ Section
                        VStack(spacing: 15) {
                            Text("Frequently Asked Questions")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 25)
                            
                            FAQItem(
                                question: "How do I analyze a meal?",
                                answer: "Simply tap the camera button on the home screen and take a photo of your meal. The AI will automatically analyze the ingredients and provide nutritional information.",
                                isExpanded: expandedSection == "analyze",
                                onTap: { expandedSection = expandedSection == "analyze" ? nil : "analyze" }
                            )
                            
                            FAQItem(
                                question: "What is the difference between demo mode and API mode?",
                                answer: "Demo mode provides sample nutritional data for testing the app. API mode uses OpenAI's advanced AI to provide real, accurate nutritional analysis of your actual meals. You can add an API key in Settings.",
                                isExpanded: expandedSection == "modes",
                                onTap: { expandedSection = expandedSection == "modes" ? nil : "modes" }
                            )
                            
                            FAQItem(
                                question: "How do I get an OpenAI API key?",
                                answer: "1. Visit platform.openai.com\n2. Create an account or sign in\n3. Navigate to API keys section\n4. Generate a new API key\n5. Copy and paste it in the Settings",
                                isExpanded: expandedSection == "apikey",
                                onTap: { expandedSection = expandedSection == "apikey" ? nil : "apikey" }
                            )
                            
                            FAQItem(
                                question: "Can I edit meal information?",
                                answer: "Currently, meals are analyzed automatically and cannot be edited. However, you can delete any meal from your history and re-analyze it if needed.",
                                isExpanded: expandedSection == "edit",
                                onTap: { expandedSection = expandedSection == "edit" ? nil : "edit" }
                            )
                            
                            FAQItem(
                                question: "Is my data safe?",
                                answer: "Yes! All your data is stored locally on your device. We don't have access to your meals, photos, or personal information. If you use an API key, photos are sent to OpenAI for analysis only.",
                                isExpanded: expandedSection == "privacy",
                                onTap: { expandedSection = expandedSection == "privacy" ? nil : "privacy" }
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Contact Section
                        VStack(spacing: 15) {
                            Text("Still need help?")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 25)
                                .padding(.top, 20)
                            
                            ContactCard(
                                icon: "envelope.fill",
                                title: "Email Support",
                                subtitle: "support@clickfitai.com",
                                color: .blue
                            )
                            
                            ContactCard(
                                icon: "globe",
                                title: "Visit Website",
                                subtitle: "www.clickfitai.com",
                                color: .green
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // Close Button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.5))
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }
                    Spacer()
                }
            )
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - FAQ Item
struct FAQItem: View {
    let question: String
    let answer: String
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(question)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(.cyan)
            }
            .padding(20)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            
            if isExpanded {
                Text(answer)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .transition(.opacity)
            }
        }
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
        .animation(.spring(), value: isExpanded)
    }
}

// MARK: - Contact Card
struct ContactCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "arrow.up.right")
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
    }
}

// MARK: - Rating Popup View
struct RatingPopupView: View {
    @Binding var userRating: Int
    @Binding var hasRated: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRating: Int = 0
    @State private var showThankYou = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    
                    Text("Rate ClickFit AI")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Your feedback helps us improve")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Stars
                HStack(spacing: 15) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= (selectedRating == 0 ? userRating : selectedRating) ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                            .scaleEffect(index <= selectedRating ? 1.2 : 1.0)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedRating = index
                                }
                            }
                    }
                }
                .padding(.vertical, 20)
                
                // Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        if selectedRating > 0 {
                            userRating = selectedRating
                            hasRated = true
                            UserDefaults.standard.set(selectedRating, forKey: "userRating")
                            
                            withAnimation {
                                showThankYou = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        }
                    }) {
                        Text(showThankYou ? "Thank You! 🎉" : "Submit Rating")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .opacity(selectedRating > 0 ? 1 : 0.5)
                            )
                            .cornerRadius(15)
                    }
                    .disabled(selectedRating == 0)
                    
                    Button("Maybe Later") {
                        dismiss()
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.1, green: 0.1, blue: 0.15),
                                Color(red: 0.05, green: 0.05, blue: 0.1)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(40)
        }
        .onAppear {
            selectedRating = userRating
        }
    }
}