import Foundation
import UIKit

struct Constants {
    struct API {
        // NO hardcoded API key - users must enter their own in Settings
        static let timeout: TimeInterval = 60
    }
    
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let animationDuration: Double = 0.3
    }
    
    struct Storage {
        static let maxImageSize = 1_048_576 // 1MB
        static let compressionQuality: CGFloat = 0.8
    }
}