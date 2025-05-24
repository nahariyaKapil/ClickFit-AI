//
//  ContentView.swift
//  ClickFit AI
//
//  Created by Kapil Nahariya on 24/05/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataController = DataController()
    @State private var selectedTab = 0
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                TabView(selection: $selectedTab) {
                    CameraView()
                        .tabItem {
                            VStack {
                                Image(systemName: selectedTab == 0 ? "camera.fill" : "camera")
                                Text("Capture")
                            }
                        }
                        .tag(0)
                    
                    HistoryView()
                        .tabItem {
                            VStack {
                                Image(systemName: selectedTab == 1 ? "calendar.circle.fill" : "calendar")
                                Text("History")
                            }
                        }
                        .tag(1)
                    
                    SettingsView()
                        .tabItem {
                            VStack {
                                Image(systemName: selectedTab == 2 ? "gearshape.fill" : "gearshape")
                                Text("Settings")
                            }
                        }
                        .tag(2)
                }
                .environmentObject(dataController)
                .accentColor(.white)
                .onAppear {
                    setupTabBarAppearance()
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        // Unselected state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Splash Screen
struct SplashView: View {
    @State private var animate = false
    @State private var showText = false
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Animated Logo
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: animate ? 0 : 10)
                        .scaleEffect(animate ? 1 : 0.5)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .scaleEffect(animate ? 1 : 0)
                        .rotationEffect(.degrees(animate ? 0 : -180))
                }
                
                VStack(spacing: 10) {
                    Text("ClickFit AI")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)
                    
                    Text("AI-Powered Nutrition Analysis")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.8))
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 20)
                }
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .opacity(showText ? 1 : 0)
                    .padding(.top, 50)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                animate = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                showText = true
            }
        }
    }
}