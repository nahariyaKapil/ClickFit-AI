# ClickFit AI - AI-Powered Food Analysis iOS App

A Swift-based iOS application that uses OpenAI's Vision API to analyze food photos and provide detailed nutritional information.

## Features

- 📸 **Camera Integration**: Capture food photos directly or select from gallery
- 🤖 **AI Analysis**: Automatic food recognition and nutritional breakdown using OpenAI Vision API
- ✏️ **Editable Results**: Modify ingredients and quantities with real-time calorie updates
- 📅 **History Tracking**: Calendar view with daily, weekly, and monthly summaries
- 🌙 **Dark Mode Support**: Seamless light/dark theme switching
- ♿ **Accessibility**: Full VoiceOver support

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- OpenAI API Key
- CocoaPods or Swift Package Manager (optional)

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/nahariyaKapil/ClickFit-AI.git
cd ClickFit-AI
```

### 2. Set Up OpenAI API Key

#### Option A: Environment Variable (Recommended for Development)
1. Open Xcode
2. Select your scheme → Edit Scheme
3. Go to Run → Arguments → Environment Variables
4. Add: `OPENAI_API_KEY` = `your-api-key-here`

#### Option B: Direct Configuration
1. Open `Utils/Constants.swift`
2. Replace `YOUR_OPENAI_API_KEY` with your actual API key
3. **Important**: Never commit API keys to version control

### 3. Configure Project Settings
1. Open `ClickFit AI.xcodeproj` in Xcode
2. Select the project in navigator
3. Update Bundle Identifier to something unique (e.g., `com.yourname.ClickFit-AI.`)
4. Select your Development Team
5. Configure signing certificates

### 4. Install Dependencies (if using)
```bash
# If using CocoaPods
pod install

# If using SPM, dependencies will auto-install
```

## Build & Run

### Using Xcode
1. Open `ClickFit AI.xcodeproj` (or `.xcworkspace` if using CocoaPods)
2. Select target device (iPhone simulator or real device)
3. Press `Cmd+R` to build and run

### Using Cursor + SweetPad
1. Open project in Cursor
2. Install SweetPad extension
3. Use `Cmd+Shift+P` → "SweetPad: Build and Run"
4. Select target device from SweetPad menu

## Project Structure

```
ClickFit AI/
├── App/
│   ├── ClickFit AIApp.swift         # App entry point
│   └── ContentView.swift       # Main tab view
├── Models/
│   ├── FoodAnalysis.swift      # Core data model
│   ├── Ingredient.swift        # Ingredient model
│   └── NutritionInfo.swift     # Nutrition data
├── Views/
│   ├── Camera/
│   │   ├── CameraView.swift    # Camera capture UI
│   │   └── CameraViewModel.swift
│   ├── Analysis/
│   │   ├── AnalysisView.swift  # Results display
│   │   └── IngredientRow.swift
│   └── History/
│       ├── HistoryView.swift   # Calendar view
│       └── DaySummaryView.swift
├── Services/
│   ├── OpenAIService.swift     # API integration
│   └── DataController.swift    # Data persistence
└── Utils/
    ├── Extensions.swift        # Helper extensions
    └── Constants.swift         # App constants
```

## Development Workflow

### Adding New Features
1. Create feature branch: `git checkout -b feat/feature-name`
2. Implement feature following MVVM pattern
3. Test on both simulator and device
4. Commit with conventional format: `git commit -m "feat: add feature description"`

### Debugging with Cursor AI
1. Use inline error explanations
2. Ask Cursor to explain complex Swift concepts
3. Generate boilerplate code with comments
4. Use Cursor's chat for architecture decisions

### Testing
```swift
// Run unit tests
Cmd+U

// Run UI tests
Cmd+Shift+U
```

## API Usage

### OpenAI Vision API Request Format
```json
{
  "model": "gpt-4-vision-preview",
  "messages": [{
    "role": "user",
    "content": [
      {"type": "text", "text": "Analyze food..."},
      {"type": "image_url", "image_url": {"url": "data:image/jpeg;base64,..."}}
    ]
  }],
  "max_tokens": 1000,
  "response_format": {"type": "json_object"}
}
```

### Rate Limits
- 500 requests per day (Tier 1)
- Max image size: 20MB (we compress to 1MB)
- Timeout: 30 seconds

## Troubleshooting

### Common Issues

1. **Camera Permission Denied**
   - Go to Settings → ClickFit AI → Enable Camera
   - Reset permissions in Settings → General → Reset

2. **API Key Invalid**
   - Verify key in OpenAI dashboard
   - Check for extra spaces or characters
   - Ensure billing is active

3. **Build Errors**
   - Clean build folder: `Cmd+Shift+K`
   - Delete derived data
   - Update to latest Xcode

4. **SweetPad Connection Issues**
   - Restart VS Code/Cursor
   - Check device is on same network
   - Update SweetPad extension

## Performance Optimization

- Images compressed to <1MB before API calls
- Lazy loading in history view
- Debounced search in ingredient editor
- Cached API responses for 24 hours

## Deployment

### TestFlight (Bonus)
1. Archive app: Product → Archive
2. Upload to App Store Connect
3. Add external testers
4. Submit for beta review

### App Store Submission
1. Create app in App Store Connect
2. Prepare screenshots (6.5" and 5.5")
3. Write description and keywords
4. Submit for review

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes with conventional commits
4. Push to branch
5. Create Pull Request

## License

This project is for demonstration purposes as part of the AppsClicks interview process.

## Contact

- **Email**: nahariyakapil@gmail.com
- **LinkedIn**: [(https://www.linkedin.com/in/kapil-nahariya-06b332163/)]

---

Built with ❤️ using SwiftUI and OpenAI Vision API
