//
//  ClickFit_AIApp.swift
//  ClickFit AI
//
//  Created by Kapil Nahariya on 24/05/25.
//

import SwiftUI

@main
struct ClickFit_AIApp: App {
    @StateObject private var dataController = DataController()
    
    init() {
        // Configure app appearance
        setupAppearance()
        
        print("🚀 ClickFit AI app initialized - Users can add API key in Settings for real analysis")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataController)
                .preferredColorScheme(.dark) // Force dark mode for modern UI
        }
    }
    
    private func setupAppearance() {
        // Configure navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        
        // Configure tab bar appearance (handled in ContentView)
        
        // Configure other UI elements
        UITextField.appearance().tintColor = UIColor.cyan
        UITextView.appearance().tintColor = UIColor.cyan
    }
}