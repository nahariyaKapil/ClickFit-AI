import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataController: DataController
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    
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
                
                VStack(spacing: 0) {
                    // Modern Header - Fixed height to prevent dancing
                    VStack(spacing: 20) {
                        HStack {
                            Text("History")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { showingDatePicker.toggle() }) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(.cyan)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 60)
                        
                        // Date Navigation
                        HStack(spacing: 20) {
                            Button(action: previousDay) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.cyan)
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(20)
                            }
                            
                            VStack(spacing: 4) {
                                Text(selectedDate.formatted(as: "EEEE"))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text(selectedDate.formatted(as: "MMMM d"))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(minWidth: 150)
                            
                            Button(action: nextDay) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Calendar.current.isDateInToday(selectedDate) ? .gray : .cyan)
                                    .frame(width: 40, height: 40)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(20)
                            }
                            .disabled(Calendar.current.isDateInToday(selectedDate))
                        }
                        
                        // Weekly Overview
                        ModernWeeklyCalendarView(selectedDate: $selectedDate, data: dataController)
                            .padding(.horizontal, 20)
                    }
                    .frame(height: 280) // Fixed height for header section
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.3),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Daily Summary
                    ScrollView {
                        VStack(spacing: 20) {
                            // Daily Stats Card
                            ModernDailyStatsCard(
                                date: selectedDate,
                                totalCalories: dataController.totalCalories(for: selectedDate),
                                mealCount: dataController.analyses(for: selectedDate).count
                            )
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // Meals List
                            if dataController.analyses(for: selectedDate).isEmpty {
                                ModernEmptyStateView()
                                    .padding(.top, 50)
                            } else {
                                ForEach(dataController.analyses(for: selectedDate)) { analysis in
                                    ModernMealCard(analysis: analysis) {
                                        withAnimation(.spring()) {
                                            dataController.delete(analysis)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingDatePicker) {
                ModernDatePickerSheet(selectedDate: $selectedDate)
            }
        }
    }
    
    private func previousDay() {
        withAnimation(.spring()) {
            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func nextDay() {
        if !Calendar.current.isDateInToday(selectedDate) {
            withAnimation(.spring()) {
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            }
        }
    }
}

// MARK: - Modern Weekly Calendar View
struct ModernWeeklyCalendarView: View {
    @Binding var selectedDate: Date
    let data: DataController
    
    var weekDays: [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -6 + offset, to: today)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(weekDays, id: \.self) { date in
                VStack(spacing: 10) {
                    Text(date.formatted(as: "EEE"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                isSelected(date) ?
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 45, height: 45)
                        
                        Text(date.formatted(as: "d"))
                            .font(.system(size: 16, weight: isSelected(date) ? .bold : .medium))
                            .foregroundColor(isSelected(date) ? .white : .white.opacity(0.7))
                        
                        if data.analyses(for: date).count > 0 {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                                .offset(y: 20)
                        }
                    }
                }
                .scaleEffect(isSelected(date) ? 1.1 : 1.0)
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedDate = date
                    }
                }
            }
        }
        .frame(height: 100) // Fixed height for calendar
    }
    
    private func isSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
}

// MARK: - Modern Daily Stats Card
struct ModernDailyStatsCard: View {
    let date: Date
    let totalCalories: Int
    let mealCount: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ModernStatItem(
                icon: "flame.fill",
                value: "\(totalCalories)",
                label: "Calories",
                color: .orange,
                alignment: .leading
            )
            
            Spacer()
            
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1, height: 50)
            
            Spacer()
            
            ModernStatItem(
                icon: "fork.knife",
                value: "\(mealCount)",
                label: "Meals",
                color: .cyan,
                alignment: .trailing
            )
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
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
    }
}

// MARK: - Modern Stat Item
struct ModernStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let alignment: HorizontalAlignment
    
    var body: some View {
        VStack(alignment: alignment, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Modern Meal Card
struct ModernMealCard: View {
    let analysis: FoodAnalysis
    let onDelete: () -> Void
    @State private var showingDetail = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(analysis.mealName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text(analysis.date.formatted(as: "h:mm a"))
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(analysis.totalCalories)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)
                    
                    Text("calories")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Macros Bar with Modern Design
            HStack(spacing: 0) {
                ModernMacroBar(
                    label: "Protein",
                    value: analysis.totals.formattedProtein,
                    color: .blue,
                    percentage: min(analysis.totals.protein / 100, 1.0)
                )
                
                ModernMacroBar(
                    label: "Carbs",
                    value: analysis.totals.formattedCarbs,
                    color: .orange,
                    percentage: min(analysis.totals.carbs / 100, 1.0)
                )
                
                ModernMacroBar(
                    label: "Fat",
                    value: analysis.totals.formattedFat,
                    color: .green,
                    percentage: min(analysis.totals.fat / 100, 1.0)
                )
            }
            .frame(height: 40)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture {
            showingDetail = true
        }
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }, perform: {})
        .contextMenu {
            Button(action: { showingDetail = true }) {
                Label("View Details", systemImage: "eye.fill")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .sheet(isPresented: $showingDetail) {
            MealDetailView(analysis: analysis)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Modern Macro Bar
struct ModernMacroBar: View {
    let label: String
    let value: String
    let color: Color
    let percentage: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.clear)
                
                // Progress bar
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.6)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * percentage)
                
                // Text overlay
                HStack {
                    Text("\(label): \(value)g")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 12)
            }
        }
    }
}

// MARK: - Modern Empty State View
struct ModernEmptyStateView: View {
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.cyan.opacity(0.2), Color.blue.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(animate ? 1.1 : 0.9)
                    .opacity(animate ? 0.5 : 0.8)
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            VStack(spacing: 10) {
                Text("No meals recorded")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Take a photo to analyze your first meal")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Modern Date Picker Sheet
struct ModernDatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1)
                    .ignoresSafeArea()
                
                VStack {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .accentColor(.cyan)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                    )
                    .padding()
                }
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}