//
//  ThemeListView.swift
//  SnapSort
//
//  Created by Jie Lu on 13.7.2025.
//



import SwiftUI
import SwiftData

struct ThemeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var themes: [Theme]
    
    @State private var showingAddTheme = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(themes) { theme in
                        ThemeRow(theme: theme) {
                            deleteTheme(theme)
                        }
                    }
                    
                    // Empty state
                    if themes.isEmpty {
                        emptyStateView
                    }
                }
                .padding()
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddTheme) {
                AddThemeView()
            }
        }
    }
    
    // MARK: - View Components
    
    private var addButton: some View {
        Button(action: {
            showingAddTheme = true
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.blue)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Themes Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Create your first theme \n to organize your snaps")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingAddTheme = true
            }) {
                Text("Add Theme")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.purple)
                    )
            }
        }
        .padding(.top, 60)
    }
    
    // MARK: - Methods
    
    private func deleteTheme(_ theme: Theme) {
        withAnimation {
            modelContext.delete(theme)
            try? modelContext.save()
        }
    }
}

// MARK: - Add Theme View
struct AddThemeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var themeName: String = ""
    @State private var keywordsText: String = ""
    @State private var selectedColor: ThemeColor = .blue
    
    private let availableColors: [ThemeColor] = [.blue, .green, .orange, .pink]
    
    var body: some View {
        NavigationStack {
            Form {
                themeDetailsSection
                keywordsSection
                colorSection
            }
            .navigationTitle("Add New Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var themeDetailsSection: some View {
        Section("Theme Details") {
            themeNameTextEditor
        }
    }
    
    private var themeNameTextEditor: some View {
        TextEditor(text: $themeName)
            .frame(minHeight: 44)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
    
    private var keywordsSection: some View {
        Section("Keywords") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter keywords separated by space")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                keywordsTextEditor
            }
        }
    }
    
    private var keywordsTextEditor: some View {
        TextEditor(text: $keywordsText)
            .frame(minHeight: 100)
            .scrollContentBackground(.hidden)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
    
    private var colorSection: some View {
        Section("Color") {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(availableColors, id: \.self) { colorName in
                    colorButton(for: colorName)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 4)
    }
    
    private func colorButton(for colorName: ThemeColor) -> some View {
        Button(action: {
            selectedColor = colorName
        }) {
            Circle()
                .fill(colorName.swiftUIColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(selectedColor == colorName ? Color.purple : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            saveTheme()
        }
        .disabled(themeName.trimmingCharacters(in: .whitespaces).isEmpty)
    }
    
    // MARK: - Methods
    
    private func saveTheme() {
        let trimmedName = themeName.trimmingCharacters(in: .whitespaces)
        let keywords = keywordsText
            .components(separatedBy: " ")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let newTheme = Theme(
            name: trimmedName,
            keywords: keywords,
            color: selectedColor
        )
        
        modelContext.insert(newTheme)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving theme: \(error)")
        }
    }
}


// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Theme.self, configurations: config)
    
    // Add sample themes for preview
    let sampleThemes = [
        Theme(name: "Work", keywords: ["meeting", "email", "deadline", "project"], color: .blue),
        Theme(name: "Personal", keywords: ["family", "vacation", "hobby"], color: .green),
        Theme(name: "Learning", keywords: ["tutorial", "course", "study"], color: .orange)
    ]
    
    sampleThemes.forEach { container.mainContext.insert($0) }
    
    return ThemeListView()
        .modelContainer(container)
}
